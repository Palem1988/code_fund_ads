class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_user, only: [:index], if: -> { params[:user_id].present? }
  before_action :set_organization, only: [:index], if: -> { params[:organization_id].present? }
  before_action :set_campaign, only: [:index], if: -> { params[:campaign_id].present? }
  before_action :set_property, only: [:index], if: -> { params[:property_id].present? }
  before_action :set_applicant, only: [:index], if: -> { params[:applicant_id].present? }
  before_action :set_commentable, only: [:show, :create]

  def index
    @comments = @commentable.comment_threads

    render "/comments/for_user/index" if @commentable.is_a? User
    render "/comments/for_organization/index" if @commentable.is_a? Organization
    render "/comments/for_campaign/index" if @commentable.is_a? Campaign
    render "/comments/for_property/index" if @commentable.is_a? Property
    render "/comments/for_applicant/index" if @commentable.is_a? Applicant
  end

  def create
    comment = Comment.build_from(@commentable, current_user.id, params[:body])
    comment.save
    redirect_back fallback_location: root_path
  end

  def destroy
    comment = Comment.find(params[:id])
    comment.destroy
    redirect_back fallback_location: root_path
  end

  private

  def set_user
    @commentable = if authorized_user.can_admin_system?
      User.find(params[:user_id])
    else
      current_user
    end
  end

  def set_organization
    @commentable = if authorized_user.can_admin_system?
      Organization.find(params[:organization_id])
    else
      current_user.organization
    end
  end

  def set_campaign
    @commentable = if authorized_user.can_admin_system?
      Campaign.find(params[:campaign_id])
    else
      current_user.campaigns.find(params[:campaign_id])
    end
  end

  def set_property
    @commentable = if authorized_user.can_admin_system?
      Property.find(params[:property_id])
    else
      current_user.properties.find(params[:property_id])
    end
  end

  def set_applicant
    @commentable = Applicant.find(params[:applicant_id]) if authorized_user.can_admin_system?
  end

  def set_commentable
    # TODO: create an authorizer and check permissions
    @commentable = GlobalID::Locator.locate_signed(params[:sgid])
  end
end
