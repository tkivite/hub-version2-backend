# frozen_string_literal: true

class Role < ApplicationRecord
  has_many :assignments
  has_many :users, through: :assignments
  validates :name, presence: true, uniqueness: true

  enum role_type: %i[external internal]
end
