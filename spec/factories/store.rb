# frozen_string_literal: true

FactoryBot.define do
  factory :store do
    name { 'demo' }
    store_key { 'demo' }
    monthly_revenue { '1500000' }
    no_of_employess { '4' }
    target { '1000000' }
    location { 'Nairobi' }
    country { 'KE'}
  end
end

