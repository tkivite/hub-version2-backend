# frozen_string_literal: true

class User < ApplicationRecord
  # encrypt password
  has_secure_password

  # Model associations
  #   has_many :roles, foreign_key: :created_by
  has_many :assignments
  has_many :roles, through: :assignments
  # Validations
  validates_presence_of :firstname, :email, :password_digest, :othernames, :gender, :mobile

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i.freeze
  validates_uniqueness_of :email, case_sensitive: false
  validates_uniqueness_of :mobile, case_sensitive: false
  validates :email, format: { with: VALID_EMAIL_REGEX, message: 'Incorrect email format, e.g. test@lipalater.com' }

  # method to check if the user has a particular role:
  def role?(role)
    roles.any? { |r| r.name.underscore.to_sym == role }
  end
end
