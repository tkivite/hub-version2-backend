# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :set_user, only: %i[show update destroy]
  # GET /users
  def index
    @users = User.all
    authorize @users.first, :list?
    policy_scope @users
    json_response(@users, :ok)
  end

  # POST /users
  def create
    @user = User.new(user_params)
    authorize @user, :create?
    @user.status = 0
    return  json_response(@user, :unprocessable_entity) unless @user.save!
    @user.reload
    token = @user.generate_token
    payload = generate_email_payload(@user, token)
    NotificationMailerWorker.perform_async(payload)
    json_response(@user, :created)    
  end

  # GET /users/:id
  def show
    authorize @user, :view?
    json_response(@user)
  end

  # PUT /users/:id
  def update
    authorize @user, :update?
    @user.update!(user_params)
    json_response(@user, :ok)
  end

  # DELETE /users/:id
  def destroy
    authorize @user, :destroy?
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
    params.permit(:id,:firstname, :othernames, :gender, :email, :password, :mobile, :status, :created_by)
  end

  def set_user
    @user = User.find(params[:id])
  end

  def generate_email_payload(user, token)
    url = ENV['FIRST_TIME_LOGIN_URL']
    msg = "Dear #{user.firstname},"
    msg += "\n\n\t You have been created as a user on the hub. Click on the link below to set you access credentials:"
    msg += "\n\n\t URL:- #{url}/setpassword?token=#{token}&email=#{user.email}"
    msg += "\n\n\t Username:- #{user.email}"
    msg += "\n\n\t"
    msg += "\n\n\t If this email was sent by mistake kindly ignore"
    msg += "\n\n\t Should you have challenges or need our assistance feel free to call us on: 0709684000"
    to = user.email
    from = 'thehub@lipalater.com'
    {
      'subject' => 'The hub - Welcome to the hub',
      'message' => msg,
      'to' => to,
      'from' => from,
      'purpose' => 'general'
    }
  end
end
