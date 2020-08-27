class PasswordsController < ActionController::API
    include ActionController::MimeResponds
    include Response
    include ExceptionHandler
  
    # method responsible for receiving an email of a user requesting to
    # reset the password and send them a one time verification code

    def set_password

        token = params[:token].to_s
        return render json: { error: 'Token not present' } if token.blank?
        return render json: { error: 'Password is blank not present' } if params[:new_password].blank?
        return render json: { error: 'passwords do not match' } unless params[:new_password] == params[:confirm_password]

        user = User.find_by(email: params[:email])
        return render json: { error: 'user not found' } unless user.present?

        reset_record = ResetToken.where(user_id: user.id, token: token, used: false).order(created_at: :desc).first
        return render json: { error: 'invalid token' } if reset_record.nil? || reset_record.expiration < Time.now.utc

        user.password = params[:new_password]
        user.reset_tokens.update_all(used: true)
        user.save!
        payload = generate_email_payload(user)
        NotificationMailerWorker.perform_async(payload)
        json_response(user, :ok)
    end

    def forgot_password

        return render json: { error: 'Email not present' } if params[:email].blank?

        user = User.find_by(email: params[:email])
        return render json: { error: 'user not found' } unless user.present?
        token = user.generate_token
        payload = generate_forgot_password_payload(user,token)
        NotificationMailerWorker.perform_async(payload)        
        json_response(user, :ok)
    end
    
    def send_forgot_password_pin
      if params[:email].blank?
        return render json: { error: 'Email not present' }
      end
  
      # attempt to find user
      user = User.find_by(email: params[:email])
      if user.nil?
        return render json: { error: 'No such user present' }
      end
  
      generated_pin = generate_forgot_password_pin(4)
      forgot_password_pin = ForgotPasswordPin.new(pin: generated_pin, requested_at: Time.now, user_id: user.id)
  
      if forgot_password_pin.save
        # send sms here
        puts '------------------------------------------'
        one_time_pin_msg = "Your verification pin to reset your Lipa Later Vas Portal account is: #{generated_pin}. Your friends at Lipa Later."
        puts one_time_pin_msg
        puts '------------------------------------------'
        SendSmsWorker.perform_async(user.formatted_phone_number, "Lipalater", one_time_pin_msg)
        json_response(user, :created)
      else
        render json: { error: 'Unable to save pin' }
      end
    end
  
    def forgot
        if params[:email].blank?
          #check pin
          return render json: {error: 'Email not present'}
        end
  
          email = params[:email]
          pin = params[:pin]
          #security_answer = params[:security_answer]
  
        user = User.find_by(email: email.downcase)
  
        if user.nil?
          render json: {error: ['User with provided details was not found. Please check and try again.']}, status: :not_found
          return
        end
  
  
        forgot_pin = user.forgot_password_pins.where(verified: false).order(created_at: :desc).first
  
        puts "--------------------------------------------------"
        puts forgot_pin
        puts "--------------------------------------------------"
        puts forgot_pin.authenticate(pin)
        puts "--------------------------------------------------"
  
       if forgot_pin.authenticate(pin)
  
  
        user.generate_password_token!
        user.reload
        token = user.reset_password_token
        puts "sending forgot password email to user #{token} "
  
  
        puts "sending forgot password email to user "
        url = ENV["FIRST_TIME_LOGIN_URL"]
  
        msg ="Dear #{user.firstname},"
        msg += "\n\n\t You requested to reset your password for lipalater VAS portal"
        msg += "\n\n\t URL:- #{url}?token=#{token}"
        msg += "\n\n\t Username:- #{user.email}"
        msg += "\n\n\t OneTimePassword:- #{user.password}"
        msg += "\n\n\t"
        msg += "\n\n\t If this email was sent by mistake kindly ignore"
        msg += "\n\n\t Should you have challenges or need our assistance feel free to call us on: 0709684000"
        to = user.email
        from = "thehub@lipalater.com"
        begin
              puts "sending email #{to}   #{from} #{msg}"
  
              email_payload = {
                  "subject" => "The hub - Forgot Password",
                  "message" => msg,
                  "to" => to,
                  "from" => from,
                  "purpose" => 'general'
  
              }
              NotificationMailerWorker.perform_async(email_payload)
              user.active_status = false
              user.save
              render json: {status: 'ok'}, status: :ok
  
            rescue StandardError => e
              puts '------------------------------------------'
              msg = "An error occurred while sending forgot password email to #{to}  : #{e.inspect} Error Backtrace: #{e.backtrace}"
              puts msg
              puts '------------------------------------------'
              SendNotificationToSlackWorker.perform_async(msg)
              render json: {error: ['Problems Occured trying to send email.']}, status: :not_found
            end
        else
          render json: {error: ['Validation Failed !.']}, status: :not_found
        end
      end
  
    def reset
      token = params[:token].to_s
      password = params[:new_password]
  
      if params[:token].blank?
        return render json: {error: 'Token not present'}
      end
  
      user = User.find_by(reset_password_token: token)
  
      if user.present? && user.password_token_valid?
        if user.reset_password!(password)
          msg ="Dear #{user.firstname},"
          # user.save!
          url = ENV["FIRST_TIME_LOGIN_URL"]
          url = url.chomp("changepassword")
          msg += "\n\n\t Your password for the hub has been updated. Click on the link below to access:"
          msg += "\n\n\t URL:- #{url}"
          msg += "\n\n\t Username:- #{user.email}"
          # msg += "\n\n\t OneTimePassword:- #{@user.password}"
          msg += "\n\n\t"
          msg += "\n\n\t If this email was sent by mistake kindly ignore"
          msg += "\n\n\t Should you have challenges or need our assistance feel free to call us on: 0709684000"
          to = user.email
          #to = 'tkivite@gmail.com'
          from = "thehub@lipalater.com"
  
          begin
            puts "sending email to: #{to}   from: #{from}  msg: #{msg}"
            email_payload = {
                "subject" => "The hub - Welcome to Lipalater partners portal",
                "message" => msg,
                "to" => to,
                "from" => from,
                "purpose" => 'general'
  
            }
            NotificationMailerWorker.perform_async(email_payload)
  
            user.active_status = true
            user.portal_login_allowed = true
            user.save
            msg = "Your password for the hub has been updated. Please check your email for more details"
            SendSmsWorker.perform_async(user.formatted_phone_number, "Lipalater", msg)
          rescue StandardError => e
            puts '------------------------------------------'
            msg = "An error occurred while sending user creation email to #{to} with the message : #{e.inspect} Error Backtrace: #{e.backtrace}"
            puts msg
            puts '------------------------------------------'
            SendNotificationToSlackWorker.perform_async(msg)
            render json: {error: ['Problems Occurred trying to send email.']}, status: :created
            return
          end
          render json: {status: 'ok'}, status: :ok
        else
          render json: {error: user.errors.full_messages}, status: :unprocessable_entity
        end
      else
        render json: {error:  ['Link not valid or expired. Try generating a new link.']}, status: :not_found
      end
    end
  
    def resend
      puts "sending forgot password email to user #{params} "
      if params[:email].blank?
        #check pin
        render json: {error: 'Email not present'}
      else
        email = params[:email]
        user = User.where("lower(email) = ?", email.downcase).where(portal_login_allowed: true).first
  
        if user.nil?
          render json: {error: ['User with provided details was not found. Or user is not allowed to login into the system.']}, status: :not_found
  
        else
            user.generate_password_token!
            user.reload
            token = user.reset_password_token
            puts "sending forgot password email to user #{token} "
            puts "sending forgot password email to user "
            url = ENV["FIRST_TIME_LOGIN_URL"]
            msg ="Dear #{user.firstname},"
            msg += "\n\n\t You requested to reset your password for lipalater hub"
            msg += "\n\n\t URL:- #{url}?token=#{token}"
            msg += "\n\n\t Username:- #{user.email}"
            msg += "\n\n\t OneTimePassword:- #{user.password}"
            msg += "\n\n\t"
            msg += "\n\n\t If this email was sent by mistake kindly ignore"
            msg += "\n\n\t Should you have challenges or need our assistance feel free to call us on: 0709684000"
            to = user.email
            from = "thehub@lipalater.com"
            begin
              puts "sending email #{to}   #{from} #{msg}"
  
              email_payload = {
                  "subject" => "The hub - Reset Password",
                  "message" => msg,
                  "to" => to,
                  "from" => from,
                  "purpose" => 'general'
  
              }
              NotificationMailerWorker.perform_async(email_payload)
              user.active_status = false
              user.save
              render json: {status: 'ok'}, status: :ok
  
            rescue StandardError => e
              puts '------------------------------------------'
              msg = "An error occurred while sending forgot password email to #{to}  : #{e.inspect} Error Backtrace: #{e.backtrace}"
              puts msg
              puts '------------------------------------------'
              SendNotificationToSlackWorker.perform_async(msg)
              render json: {error: ['Problems Occured trying to send email.']}, status: :not_found
            end
          end
        end
  
    end
  
    def update
      if !params[:password].present?
        render json: {error: 'Password not present'}, status: :unprocessable_entity
        return
      end
  
      if current_user.reset_password(params[:password])
        render json: {status: 'ok'}, status: :ok
      else
        render json: {errors: current_user.errors.full_messages}, status: :unprocessable_entity
      end
    end
  
  
    private
  
    def passwords_params
      # whitelist params
      params.permit(:email, :token, :new_password, :confirm_password)
    end
  
    # Generates a random string digits from a set of easily readable characters
    def generate_forgot_password_pin(size = 4)
      charset = %w{ 0 1 2 3 4 6 7 9 }
      pin = (0...size).map{ charset.to_a[SecureRandom.random_number(charset.size)] }.join
      return pin
    end

    def generate_email_payload(user)      
        msg ="Dear #{user.firstname},"
        # user.save!
        url = ENV["FIRST_TIME_LOGIN_URL"]
        url = url.chomp("setpassword")
        msg += "\n\n\t Your password for the hub has been updated. Click on the link below to access the dashboard:"
        msg += "\n\n\t URL:- #{url}"
        msg += "\n\n\t Username:- #{user.email}"
        # msg += "\n\n\t OneTimePassword:- #{@user.password}"
        msg += "\n\n\t"
        msg += "\n\n\t If this email was sent by mistake kindly ignore"
        msg += "\n\n\t Should you have challenges or need our assistance feel free to call us on: 0709684000"
        to = user.email
        from = "thehub@lipalater.com"

        puts "sending email to: #{to}   from: #{from}  msg: #{msg}"
        email_payload = {
            "subject" => "The hub - Your password has been updated",
            "message" => msg,
            "to" => to,
            "from" => from,
            "purpose" => 'general'

        }
    end

    def generate_forgot_password_payload(user,token)
        url = ENV['FIRST_TIME_LOGIN_URL']
        msg ="Dear #{user.firstname},"
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
