# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ResetToken, type: :model do
  describe 'Associations' do
    it { should belong_to(:user) }
  end
end
