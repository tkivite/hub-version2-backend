# frozen_string_literal: true

class ApplicationController < ActionController::API
  include ActionController::MimeResponds
  include Response
  include ExceptionHandler
  include Pundit

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  # protect_from_forgery with: :null_session

  # Authenticate all requests
  before_action :authenticate_request

  # Enforces access right checks for individuals resources
  after_action :verify_authorized, except: :index

  # Enforces access right checks for collections
  after_action :verify_policy_scoped, only: :index

  attr_reader :current_user

  private

  def authenticate_request
    @current_user = AuthorizeApiRequest.call(request.headers).result
    unless @current_user
      render json: { error: 'Not Authenticated' }, status: 401
    end
  end
end
