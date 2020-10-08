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
  describe 'Associations' do
    it { should have_many(:assignments) }
    it { should have_many(:reset_tokens) }
    it { should have_many(:roles) }
  end
  describe 'validations' do
    before { create(:user) }
    context 'presence' do
      it { should validate_presence_of(:firstname) }
      it { should validate_presence_of(:othernames) }
      it { should validate_presence_of(:gender) }
      it { should validate_presence_of(:email) }
      it { should validate_presence_of(:mobile) }
    end
    context 'email' do
      it { should allow_value('email@addresse.foo').for(:email) }
      it { should_not allow_value('foo').for(:email) }
    end

    context 'uniqueness' do
      it { should validate_uniqueness_of(:email).case_insensitive }
      it { should validate_uniqueness_of(:mobile).case_insensitive }
    end
  end
  describe 'Enum Constraints' do
    it { should define_enum_for(:status).with_values(%i[pending active inactive deactivated deleted]) }
  end
  describe 'model methods' do
    it 'tests the model methods' do
      @user = FactoryBot.create(:user)
      expect(@user.role?('create:role')).to eq(false)
      expect(@user.generate_token).to_not eq(nil)
      expect(@user.authorization_token).to_not eq(nil)      
      expect(@user.authorization_token).to_not eq('unauthorised')
      @user.password = 'ww-pass'
      expect(@user.authorization_token).to eq('unauthorised')
    end
  end
end

# frozen_string_literal: true
