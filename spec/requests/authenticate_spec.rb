# frozen_string_literal: false

require 'rails_helper'
RSpec.describe 'Authentication', type: :request do
  before(:each) do
    # Sign up url and params
    @user = FactoryBot.create(:user)
    @login_url = '/authenticate'
    @login_params = {
      email: @user.email,
      password: @user.password
    }
    @wrong_login_params = {
      email: @user.email,
      password: @user.password + '_wrong'
    }
    # p @login_params
  end
  describe 'Create and authenticate user' do
    describe 'POST /authenticate' do
      context 'when signup params is valid' do
        before do
          @headers = {
            'Accept' => 'application/json'
          }
          post @login_url, headers: @headers, params: @login_params
        end
        it 'returns status 200' do
          expect(response).to have_http_status(200)
        end
        it 'returns auth_token as part of the body' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['access_token']).to be_present
        end
        it 'expect user object' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['user']).to be_present
        end
      end
      context 'when signup params are invalid' do
        before do
          @headers = {
            'Accept' => 'application/json'
          }
          post @login_url, headers: @headers, params: @wrong_login_params
        end
        it 'returns status 401' do
          expect(response).to have_http_status(401)
        end
        it 'returns auth_token as part of the body' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['access_token']).not_to be_present
        end
        it 'expect user object' do
          parsed_response = JSON.parse(response.body)
          expect(parsed_response['user']).not_to be_present
        end
      end
    end
  end
end
