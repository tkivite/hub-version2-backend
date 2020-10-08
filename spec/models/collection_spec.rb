# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Collection, type: :model do
  describe 'Associations' do
    it { should belong_to(:sale) }
    it { should belong_to(:store) }
    it { should belong_to(:user) }
  end
  describe 'Validations' do
    it { should validate_presence_of(:collected_by_name) }
    it { should validate_presence_of(:collected_by_id_number) }
    it { should validate_presence_of(:verification_code) }
    it { should validate_presence_of(:status) }
  end
  describe 'Enum Constraints' do
    it { should define_enum_for(:status).with_values(%i[pending collected_by_lipalater collected_by_agent collected_by_customer]) }
  end
end
