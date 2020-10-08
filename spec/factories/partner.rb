# frozen_string_literal: true

FactoryBot.define do
  factory :partner do
    name { 'demo' }
    year_of_incorporation { '1980' }
    speciality { 'Electronics' }
    no_of_branches { '4' }
    payment_terms { 'Credit' }
    credit_duration_in_days { '30' }
    location { 'Nairobi' }
  end
end