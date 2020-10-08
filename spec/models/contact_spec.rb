# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Contact, type: :model do
  describe 'Validations' do
    it { should validate_presence_of(:type) }
    it { should validate_presence_of(:title) }
    it { should validate_presence_of(:name) }
    it { should validate_presence_of(:mobile) }
    it { should validate_presence_of(:email) }
  end
end
