# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  # Association test
  # ensure User model has a 1:m relationship with the Todo model
  it { should have_many(:assignments) }
  it { should have_many(:roles).through(:assignments) }
  # Validation tests
  # ensure name, email and password_digest are present before save

  context 'valid Factory' do
    it 'has a valid factory' do
      expect(build(:user)).to be_valid
    end
  end
  context 'validations' do
    before { create(:user) }
    context 'presence' do
      it { should validate_presence_of(:firstname) }
      it { should validate_presence_of(:othernames) }
      it { should validate_presence_of(:gender) }
      it { should validate_presence_of(:email) }
      it { should validate_presence_of(:mobile) }
    end
    context 'uniqueness' do
      it { should validate_uniqueness_of(:email).case_insensitive }
      it { should validate_uniqueness_of(:mobile).case_insensitive }
    end
  end

  # context 'user should have role' do
  #   assert_not(@subject.role?(:admin))
  #   @subject.roles << Role.new(name: 'admin')
  #   assert(@subject.role?(:admin))
  # end
end
