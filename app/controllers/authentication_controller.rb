# frozen_string_literal: true

# app/controllers/authentication_controller.rb

class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request
  skip_after_action :verify_authorized
  skip_after_action :verify_policy_scoped

  def authenticate
    command = AuthenticateUser.call(params[:email], params[:password])

    if command.success?
      render json: command.result
      # render json: { auth_token: command.result }
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end
end
