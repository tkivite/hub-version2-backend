# frozen_string_literal: true

class Partner < ApplicationRecord
  has_many :stores, dependent: :destroy
  # Constants
  validates :name, :year_of_incorporation, :speciality, :location, presence: true
  validates :name, uniqueness: true
end
