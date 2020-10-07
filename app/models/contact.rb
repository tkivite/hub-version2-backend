# frozen_string_literal: true

class Contact < ApplicationRecord
  # model association

  # validations
  validates :type, :name, :title, :mobile, :email, presence: true
end
