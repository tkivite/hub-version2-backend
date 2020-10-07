# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Store, type: :model do
  describe 'Associations' do
    it { should have_many(:store_accounts) }
    it { should have_many(:users) }
    it { should belong_to(:partner) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:store_key) }
    it { should validate_presence_of(:country) }
  end
end
