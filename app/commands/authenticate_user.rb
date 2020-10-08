# frozen_string_literal: true

# app/commands/authenticate_user.rb

class AuthenticateUser
  prepend SimpleCommand
  def initialize(email, password)
    @email = email
    @password = password
  end

  def call
    return errors.add :user_authentication, 'invalid credentials' unless user

    token = JsonWebToken.encode(user_id: user.id)
    { user: user, user_roles: user.roles, access_token: token }
  end

  private

  attr_accessor :email, :password

  def user
    user = User.includes(:roles).where(email: email).first
    return user if user&.authenticate(password)

    errors.add :user_authentication, 'invalid credentials'
    nil
  end
end
