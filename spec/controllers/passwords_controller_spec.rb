# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PasswordsController, type: :controller do
  before(:each) do
    @logged_in_user = FactoryBot.create(:user)
    @token = @logged_in_user.generate_token
    @set_password_valid_params = {
      new_password: 'password',
      confirm_password: 'password',
      email: @logged_in_user.email,
      token: @token
    }

    @set_password_missing_token = {
      new_password: 'password',
      confirm_password: 'password',
      email: @logged_in_user.email
    }
    @set_password_missing_new_password = {

      confirm_password: 'password',
      email: @logged_in_user.email,
      token: @token
    }
    @set_password_mismatch = {
      new_password: 'password',
      confirm_password: 'p2assword',
      email: @logged_in_user.email,
      token: @token
    }
    @set_password_missing_email = {
      new_password: 'password',
      confirm_password: 'password',
      token: @token
    }
    @set_password_wrong_token = {
      new_password: 'password',
      confirm_password: 'password',
      email: @logged_in_user.email,
      token: '12w344qqq_p20_not_valid'
    }
  end

  describe 'POST set_password' do
    context 'with valid params' do
      it 'successfully sets user password' do
        p @set_password_valid_params
        post :set_password, params: @set_password_valid_params, as: :json
        expect(response).to be_successful
        b = JSON.parse(response.body)
        expect(response).to have_http_status(201)
        expect(b['id']).to_not eq(nil)
        expect(AuthenticateUser.call(@set_password_valid_params[:email], @set_password_valid_params[:new_password]).success?).to eq(true)
        expect(b['firstname']).to eq(@logged_in_user.firstname)
        expect(b['email']).to eq(@logged_in_user.email)
        expect(b['mobile']).to eq(@logged_in_user.mobile)
      end
    end

    context 'with missing token' do
      it 'return token not present' do
        post :set_password, params: @set_password_missing_token, as: :json
        expect(response).to_not be_successful
        expect(response).to have_http_status(422)
        b = JSON.parse response.body
        expect(b['error']).to eq('Token not present')
      end
    end
    context 'with missing new password' do
      it 'return new password is blank' do
        post :set_password, params: @set_password_missing_new_password, as: :json
        expect(response).to_not be_successful
        expect(response).to have_http_status(422)
        b = JSON.parse response.body
        expect(b['error']).to eq('New password is blank')
      end
    end
    context 'with missing email' do
      it 'return user not found' do
        post :set_password, params: @set_password_missing_email, as: :json
        expect(response).to_not be_successful
        expect(response).to have_http_status(422)
        b = JSON.parse response.body
        expect(b['error']).to eq('user not found')
      end
    end
    context 'with wrong token' do
      it 'return invalid token' do
        post :set_password, params: @set_password_wrong_token, as: :json
        expect(response).to_not be_successful
        expect(response).to have_http_status(422)
        b = JSON.parse response.body
        expect(b['error']).to eq('invalid token')
      end
    end
    context 'with password mismatch' do
      it 'return passwords do not match' do
        post :set_password, params: @set_password_mismatch, as: :json
        expect(response).to_not be_successful
        expect(response).to have_http_status(422)
        b = JSON.parse response.body
        expect(b['error']).to eq('passwords do not match')
      end
    end
  end

  describe 'POST forgot_password' do
    context 'with valid params' do
      it 'successfully sends forgot password request' do
        post :forgot_password, params: { email: @logged_in_user.email }, as: :json
        expect(response).to be_successful
        b = JSON.parse(response.body)
        expect(response).to have_http_status(200)
        expect(b['id']).to_not eq(nil)
        expect(b['firstname']).to eq(@logged_in_user.firstname)
        expect(b['email']).to eq(@logged_in_user.email)
        expect(b['mobile']).to eq(@logged_in_user.mobile)
      end
    end

    context 'with missing email' do
      it 'return email not present' do
        post :forgot_password, params: { something_else: 'a_joke' }, as: :json
        expect(response).to_not be_successful
        expect(response).to have_http_status(422)
        b = JSON.parse response.body
        expect(b['error']).to eq('Email not present')
      end
    end
    context 'with wrong_email' do
      it 'return user not found' do
        post :forgot_password, params: { email: 'a_joke@jokers_corner.org' }, as: :json
        expect(response).to_not be_successful
        expect(response).to have_http_status(404)
        b = JSON.parse response.body
        expect(b['error']).to eq('user not found')
      end
    end
  end
end
