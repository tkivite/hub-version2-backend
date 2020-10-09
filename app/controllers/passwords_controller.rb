# frozen_string_literal: true

class PasswordsController < ActionController::API
  include ActionController::MimeResponds
  include Response
  include ExceptionHandler

  # method responsible for receiving an email of a user requesting to
  # reset the password and send them a one time verification code

  def set_password
    if passwords_params[:token].blank?
      return render json: { error: 'Token not present' }, status: :unprocessable_entity
    end
    # render json: { partners: partners_filtered, total_records: total_records }, status: :ok
    if passwords_params[:new_password].blank?
      return render json: { error: 'New password is blank' }, status: :unprocessable_entity
    end

    unless passwords_params[:new_password] == passwords_params[:confirm_password]
      return render json: { error: 'passwords do not match' }, status: :unprocessable_entity
    end

    user = User.find_by(email: passwords_params[:email])
    unless user.present?
      return render json: { error: 'user not found' }, status: :unprocessable_entity
    end

    reset_record = ResetToken.where(user_id: user.id, token: passwords_params[:token].to_s, used: false).order(created_at: :desc).first
    if reset_record.nil? || reset_record.expiration < Time.now.utc
      return render json: { error: 'invalid token' }, status: :unprocessable_entity
    end

    user.password = passwords_params[:new_password]
    user.reset_tokens.update_all(used: true)
    user.save!
    payload = generate_email_payload(user)
    NotificationMailerWorker.perform_async(payload)
    json_response(user, :created)
  end

  def forgot_password
    if passwords_params[:email].blank?
      return render json: { error: 'Email not present' }, status: :unprocessable_entity
    end

    user = User.find_by(email: passwords_params[:email])
    unless user.present?
      return render json: { error: 'user not found' }, status: :not_found
    end

    token = user.generate_token
    payload = generate_forgot_password_payload(user, token)
    NotificationMailerWorker.perform_async(payload)
    json_response(user, :ok)
  end

  private

  def passwords_params
    # whitelist params
    params.permit(:email, :token, :new_password, :confirm_password)
  end

  def generate_email_payload(user)
    msg = "Dear #{user.firstname},"
    # user.save!
    url = ENV['FIRST_TIME_LOGIN_URL']
    url = url.chomp('setpassword')
    msg += "\n\n\t Your password for the hub has been updated. Click on the link below to access the dashboard:"
    msg += "\n\n\t URL:- #{url}"
    msg += "\n\n\t Username:- #{user.email}"
    # msg += "\n\n\t OneTimePassword:- #{@user.password}"
    msg += "\n\n\t"
    msg += "\n\n\t If this email was sent by mistake kindly ignore"
    msg += "\n\n\t Should you have challenges or need our assistance feel free to call us on: 0709684000"
    to = user.email
    from = 'thehub@lipalater.com'

    puts "sending email to: #{to}   from: #{from}  msg: #{msg}"
    {
      'subject' => 'The hub - Your password has been updated',
      'message' => msg,
      'to' => to,
      'from' => from,
      'purpose' => 'general'

    }
  end

  def generate_forgot_password_payload(user, token)
    url = ENV['FIRST_TIME_LOGIN_URL']
    msg = "Dear #{user.firstname},"
    msg += "\n\n\t You requested to update your password on the hub. Click on the link below to set a new strong password:"
    msg += "\n\n\t URL:- #{url}/setpassword?token=#{token}&email=#{user.email}"
    msg += "\n\n\t Username:- #{user.email}"
    msg += "\n\n\t"
    msg += "\n\n\t If this email was sent by mistake kindly ignore"
    msg += "\n\n\t Should you have challenges or need our assistance feel free to call us on: 0709684000"
    to = user.email
    from = 'thehub@lipalater.com'
    {
      'subject' => 'The hub - Forgot password?',
      'message' => msg,
      'to' => to,
      'from' => from,
      'purpose' => 'general'
    }
  end
end
