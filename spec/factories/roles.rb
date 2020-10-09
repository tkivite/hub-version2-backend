# frozen_string_literal: true

FactoryBot.define do
  factory :role do
    name { 'developer' }
    permissions { %w[role:show role:create role:update] }
  end
  factory :role1, class: Role do
    name { 'developer1' }
    permissions { %w[role:show role:create role:update] }
  end
end
