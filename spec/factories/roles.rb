# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    name { 'developer' }
    created_by { '1tw62222' }
    permissions { %w[role:show] }
  end
end
