# frozen_string_literal: true

class User < ApplicationRecord
  # encrypt password
  has_secure_password

  # Model associations
  #   has_many :roles, foreign_key: :created_by
  has_many :assignments
  has_many :reset_tokens
  has_many :roles, through: :assignments

  enum status: %i[pending active inactive deactivated deleted]
  # Validations
  validates_presence_of :firstname, :email, :othernames, :gender, :mobile

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates_uniqueness_of :email, case_sensitive: false
  validates_uniqueness_of :mobile, case_sensitive: false
  validates :email, format: { with: VALID_EMAIL_REGEX, message: 'Incorrect email format, e.g. test@lipalater.com' }

  # method to check if the user has a particular role:
  def role?(role)
    roles.any? { |r| r.name.underscore.to_sym == role }
  end

  def generate_token
    reset_tokens.update_all(used: true)
    token = SecureRandom.hex(10)
    reset_token = ResetToken.new
    reset_token.user_id = id
    reset_token.token = token
    reset_token.used = false
    reset_token.expiration = Time.now.utc + 24.hours
    reset_token.save!
    token
  end

  def authorization_token
    command = AuthenticateUser.call(email, password)

    if command.success?
      # p command.result
      command.result[:access_token]

      # { json: command.result }
      # render json: { auth_token: command.result }
    else
      'unauthorised'
      # { json: { error: command.errors }, status: :unauthorized }
    end
  end
end
