# frozen_string_literal: true

class Sale < ApplicationRecord
  validates :customer_phone_number, :customer_id_number, :buying_price, :approved_amount, :item, :item_type, :store, :pick_up_type, presence: true
  validates :external_id, uniqueness: true
end
