# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include Response
  include ExceptionHandler
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session

  # Globally rescue Authorization Errors in controller.
  # Returning 403 Forbidden if permission is denied
  rescue_from Pundit::NotAuthorizedError, with: :permission_denied

  # Authenticate all requests
  # before_action :authenticate_request

  # Enforces access right checks for individuals resources
  after_action :verify_authorized, except: :index
  # Enforces access right checks for collections
  after_action :verify_policy_scoped

  attr_reader :current_user

  private

  # def authenticate_request
  #   @current_user = AuthorizeApiRequest.call(request.headers).result
  #   render json: { error: 'Not Authorized' }, status: 401 unless @current_user
  # end

  def permission_denied
    unless @current_user
      render json: { error: 'Permission denied' }, status: 403
    end
    # head 403
  end
end
