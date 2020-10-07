# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Partner, type: :model do
  describe 'Associations' do
    it { should have_many(:stores) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:year_of_incorporation) }
    it { should validate_presence_of(:speciality) }
    it { should validate_presence_of(:location) }
    it { should validate_uniqueness_of(:name) }
  end
end
