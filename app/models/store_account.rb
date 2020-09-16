# frozen_string_literal: true

class StoreAccount < ApplicationRecord
  # model association
  belongs_to :store
  # validations
  validates :type, :channel, :account_number, presence: true
end
