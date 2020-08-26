# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]

  # GET /users
  def index
    json_response(@users, :ok)
  end

  # POST /users
  def create
    @user = User.new(user_params)
    @user.active_status = true

    # if @user.save!
    #   puts '------------------------------------------'
    #   msg = "A new user has been created. Details Name: #{@user.firstname} Email: #{@user.email}"
    #   puts msg
    #   puts '------------------------------------------'

    #   @user.generate_password_token!
    #   @user.reload
    #   url = ENV['FIRST_TIME_LOGIN_URL']
    #   puts "creating #{user_params}"
    #   token = @user.reset_password_token
    #   msg += "\n\n\t You have been created as a user on Lipalater VAS portal. Click on the link below to set you access credentials:"
    #   msg += "\n\n\t URL:- #{url}?token=#{token}"
    #   msg += "\n\n\t Username:- #{@user.email}"
    #   msg += "\n\n\t"
    #   msg += "\n\n\t If this email was sent by mistake kindly ignore"
    #   msg += "\n\n\t Should you have challenges or need our assistance feel free to call us on: 0709684000"
    #   to = @user.email
    #   from = 'thehub@lipalater.com'
    #   begin
    #     puts "sending email to: #{to}   from: #{from}  msg: #{msg}"
    #     email_payload = {
    #       'subject' => 'The hub - Welcome to the hub',
    #       'message' => msg,
    #       'to' => to,
    #       'from' => from,
    #       'purpose' => 'general'

    #     }
    #     NotificationMailerWorker.perform_async(email_payload)
    #     @user.status = 0
    #     @user.save
    #   rescue StandardError => e
    #     puts '------------------------------------------'
    #     msg = "An error occurred while sending user creation email to #{to} with the message : #{e.inspect} Error Backtrace: #{e.backtrace}"
    #     puts msg
    #     puts '------------------------------------------'
    #     render json: { error: ['Problems Occurred trying to send email.'] }, status: :created
    #     return
    #   end

    # else
    #   render json: { error: ['Problems Occurred trying to save user record.'] }, status: :error
    #   return
    # end
    json_response(@user, :created)
  end

  # GET /users/:id
  def show
    json_response(@user)
  end

  # PUT /users/:id
  def update
    @user.update!(user_params)
    json_response(@user)
  end

  # DELETE /users/:id
  def destroy
    @user.destroy
    # @users = User.all
    json_response(@users)
    # respond_to do |format|
    #   format.json { render json: @users.to_json(include: { store: { only: :name } }) }
    # end
  end

  private

  def user_params
    # whitelist params
    params.permit(:firstname, :othernames, :gender, :email, :password, :mobile, :status)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def get_apps_by_store; end
end
