# frozen_string_literal: true

class Store < ApplicationRecord
  # model association
  has_many :store_accounts, dependent: :destroy
  has_many :users, dependent: :destroy
  belongs_to :partner
  # validations
  validates :name, :store_key, :country, presence: true
  validates :name, uniqueness: true
end
