# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Role, type: :model do
  describe 'Associations' do
    it { should have_many(:assignments) }
    it { should have_many(:users).through(:assignments) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_uniqueness_of(:name) }
  end
  describe 'Enum Constraints' do
    it { should define_enum_for(:role_type).with_values(%i[external internal]) }
  end
end
