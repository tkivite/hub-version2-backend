# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Sale, type: :model do
  # describe 'Associations' do
  #   it { should belong_to(:sale) }
  #   it { should belong_to(:store) }
  #   it { should belong_to(:user) }
  # end
  describe 'Validations' do
    it { should validate_presence_of(:customer_phone_number) }
    it { should validate_presence_of(:customer_id_number) }
    it { should validate_presence_of(:buying_price) }
    it { should validate_presence_of(:approved_amount) }

    it { should validate_presence_of(:item) }
    it { should validate_presence_of(:item_type) }
    it { should validate_presence_of(:store) }
    it { should validate_presence_of(:pick_up_type) }

    it { should validate_uniqueness_of(:external_id) }
  end
  # describe 'Enum Constraints' do
  #   it { should define_enum_for(:status).with_values(%i[pending collected_by_lipalater collected_by_agent collected_by_customer]) }
  # end
end
