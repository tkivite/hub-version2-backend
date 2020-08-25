# frozen_string_literal: true

class User < ApplicationRecord
  # encrypt password
  has_secure_password

  # Model associations
  #   has_many :roles, foreign_key: :created_by
  has_many :assignments
  has_many :roles, through: :assignments
  # Validations
  validates_presence_of :name, :email, :password_digest, :othernames, :gender, :mobile

  # method to check if the user has a particular role:
  def role?(role)
    roles.any? { |r| r.name.underscore.to_sym == role }
  end
end
