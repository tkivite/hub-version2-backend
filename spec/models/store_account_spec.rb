# frozen_string_literal: true

require 'rails_helper'

RSpec.describe StoreAccount, type: :model do
  describe 'Associations' do
    it { should belong_to(:store) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:channel) }
    it { should validate_presence_of(:account_number) }
  end
end
