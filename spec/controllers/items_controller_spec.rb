# frozen_string_literal: true

require 'rails_helper'
RSpec.describe ItemsController, type: :controller do
  before(:each) do

    @user = FactoryBot.create(:user)
    
    request.headers['Authorization'] = @user.authorization_token

    lipalater_core_base_url = ENV['LIPALATER_CORE_BASE_URL']
    lipalater_core_base_url = lipalater_core_base_url[-1] == '/' ? lipalater_core_base_url : lipalater_core_base_url + '/'
    response_data_fetch = { status: true, description: 'success', payload: {"id":"custid"} }.to_json
    response_data_save_facility = { status: true, description: 'Success' }.to_json
    stub_request(:post, "#{lipalater_core_base_url}fetch_client")
      .to_return({ status: 'Ok', body: response_data_fetch.to_s, headers: {} })
    stub_request(:put, "#{lipalater_core_base_url}save_client_facilities")
      .to_return({ status: 'Ok', body: response_data_save_facility.to_s, headers: {} })
  end

  describe 'POST fetch client' do
    context 'with valid params' do
      it 'successfully fetches client from core' do
       params = {
          id_number: '2222222',
          store: 'jkiarie'
        }
        post :fetch_client, params: params, as: :json
        p response
        p response.body
        expect(response).to be_successful
        b = JSON.parse(response.body)
        p b
        expect(b['status']).to eq(response_data_fetch['status'])
        expect(b['description']).to eq(response_data_fetch['description'])
        expect(b['payload']).to eq(response_data_fetch['payload'])
      end
    end
  end
  describe 'POST save facilities' do
    context 'with valid params' do
      it 'successfully saves facilities in core' do
        sales = { "facilities": [] }
        post :save_facilities, params: sales, as: :json
        expect(response).to be_successful
        b = JSON.parse(response.body)
        expect(b['status']).to eq(response_data_save_facility['status'])
        expect(b['description']).to eq(response_data_save_facility['description'])
      end
    end
  end
end
