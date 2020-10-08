# frozen_string_literal: true

require 'rails_helper'
RSpec.describe 'Authorization', type: :request do
  before(:each) do
    # Sign up url and params
    @user = FactoryBot.create(:user)
    @role = FactoryBot.create(:role)
    @permissions = %w[role:create role:show]
    @wrong_permissions = %w[role:show]

    # p @login_params
  end
  describe 'Deny user access' do
    context 'without role:create' do
      let(:role) { create(:role) }
      before(:each) { @role.permissions = @permissions }
      before(:each) { @user.roles << @role }

      # it 'denies' do
      #   should_not permit(@user, role)
      # end
    end
  end
end
