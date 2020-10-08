# frozen_string_literal: true

class Collection < ApplicationRecord
  belongs_to :store
  belongs_to :sale
  belongs_to :user
  enum status: %i[pending collected_by_lipalater collected_by_agent collected_by_customer]
  validates :collected_by_name, :collected_by_id_number, :verification_code, :status, presence: true
end
