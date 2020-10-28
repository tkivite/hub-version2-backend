# frozen_string_literal: true

require 'rails_helper'
RSpec.describe Api::V1::DisbursedsController, type: :controller do
  before(:each) do
    @partner = FactoryBot.create(:partner)
    @store = FactoryBot.create(:store, partner: @partner)
    @sales1 = {
      "facilities": [
        {
          "musoni_loan_id": '4107597',
          "principal_amount": 0,
          "interest_rate": 8,
          "loan_duration": 12,
          "facility_status": 'pending_collection_customer',
          "preferred_option": 'pick_up',
          "facility_description": 'Unde eos sunt. Alias enim fuga.',
          "facility_plan": '',
          "created_at": '2020-10-05T08:38:39.303Z',
          "updated_at": '2020-10-05T09:32:28.011Z',
          "item_type": 'tablet',
          "item_brand": 'ASUS',
          "item_code": '',
          "store_name": '',
          "item_value": 8000,
          "delivery_option": 'customer_store_pickup',
          "item_description": 'ASUS 10inch tablet',
          "accepted_terms": true,
          "item_topup": 0,
          "topup_ref": '',
          "id": 'e1814f76-fdc5-442d-a9a2-47b2559eda9b0',
          "loan_application_detail_id": '4d9536fe-16d6-4833-9565-1e9b7d21cfeb',
          "partner_store_id": '94388f63-b7fd-4be5-819e-13ca24bf339e',
          "loan_product_id": '',
          "loan_application_detail": {
            "credit_limit": 0,
            "crb_report_type": '',
            "used_credit_limit": false,
            "loan_application_status": 'loan_disbursed',
            "credit_limit_status": '',
            "created_at": '2020-10-05T08:38:39.287Z',
            "updated_at": '2020-10-05T08:52:02.796Z',
            "musoni_loan_id": '',
            "max_limit": 0,
            "assignee": '',
            "cold_call": false,
            "musoni_outstanding_balance": '',
            "credit_option": 0,
            "referral_source": 'website',
            "musoni_outstanding_principal": 0,
            "approval_type": '',
            "approval_date": '',
            "limit_activated_at": '',
            "customer_id": '09386b7e-1ccb-4f8c-beb8-13f479a9b73a',
            "id": '4d9536fe-16d6-4833-9565-1e9b7d21cfeb',
            "initial_principal_amount": 144_126,
            "interest_rate": 4,
            "loan_duration": 4,
            "accepted_terms": true,
            "loan_product_id": 'c947ae5b-b6d7-4fd0-9fea-857a62d68008',
            "disbursed_at": '',
            "expected_disbursal_date": '',
            "credit_limit_description": ''
          },
          "credit_limit_detail": {
            "id": '31ff4005-97d4-41ea-8951-de665ff356e6',
            "available_limit": 303_086,
            "credit_limit": 93_226,
            "credit_score_report": 'deliquency_report',
            "credit_score_notes": '',
            "credit_limit_status": 'limit_active',
            "credit_option": 'option_1',
            "approval_type": 'auto_approval',
            "customer_id": '09386b7e-1ccb-4f8c-beb8-13f479a9b73a',
            "approved_at": '2020-10-05T08:38:39.266Z',
            "limit_activated_at": '2020-10-05T08:38:39.266Z',
            "deleted_at": '',
            "created_at": '2020-10-05T08:38:39.269Z',
            "updated_at": '2020-10-05T08:38:39.269Z'
          },
          "customer": {
            "provider": 'email',
            "uid": 'cassey@mcclure.com',
            "allow_password_change": false,
            "name": 'Corrinne',
            "nickname": '',
            "image": '',
            "email": 'cassey@mcclure.com',
            "created_at": '2020-10-05T08:38:38.683Z',
            "updated_at": '2020-10-05T08:38:38.683Z',
            "first_name": 'Jamie',
            "last_name": 'Bayer',
            "id_number": '9804194429086',
            "phone_number": '719840515',
            "date_of_birth": '1959-04-11T00:00:00.000Z',
            "marital_status": 'married',
            "gender": 'other',
            "employed": false,
            "musoni_id": '',
            "customer_standing": 'good',
            "status": 0,
            "countries_id": '2b0e3be4-ac32-4b2f-9423-471f032465f6',
            "id": '09386b7e-1ccb-4f8c-beb8-13f479a9b73a',
            "cold_call": false,
            "referral_source": '',
            "assignee": ''
          },
          "partner_store": {
            "store_name": 'Friesen-Keeling',
            "store_location": 'mombasa',
            "store_phone_numbers": '1-835-403-6633 x90162',
            "created_at": '2020-10-05T08:38:38.188Z',
            "updated_at": '2020-10-05T08:38:38.188Z',
            "store_key": @store.store_key,
            "id": '94388f63-b7fd-4be5-819e-13ca24bf339e',
            "partner_id": '42a69a50-a947-44a8-aa0e-7a3c98ec5967',
            "country": ''
          },
          "country": {
            "id": '2b0e3be4-ac32-4b2f-9423-471f032465f6',
            "alpha_2_code": 'KE',
            "calling_code": '254',
            "deleted_at": '',
            "created_at": '2020-10-05T08:38:38.243Z',
            "updated_at": '2020-10-05T08:38:38.243Z'
          }
        },
        {
          "musoni_loan_id": '4107597',
          "principal_amount": 0,
          "interest_rate": 8,
          "loan_duration": 12,
          "facility_status": 'pending_collection_customer',
          "preferred_option": 'pick_up',
          "facility_description": 'Unde eos sunt. Alias enim fuga.',
          "facility_plan": '',
          "created_at": '2020-10-05T08:38:39.303Z',
          "updated_at": '2020-10-05T09:32:28.011Z',
          "item_type": 'tablet',
          "item_brand": 'ASUS',
          "item_code": '',
          "store_name": '',
          "item_value": 8000,
          "delivery_option": 'customer_store_pickup',
          "item_description": 'ASUS 10inch tablet',
          "accepted_terms": true,
          "item_topup": 0,
          "topup_ref": '',
          "id": 'e1814f76-fdc5-442d-a9a2-47b2559eda9b1',
          "loan_application_detail_id": '4d9536fe-16d6-4833-9565-1e9b7d21cfeb',
          "partner_store_id": '94388f63-b7fd-4be5-819e-13ca24bf339e',
          "loan_product_id": '',
          "loan_application_detail": {
            "credit_limit": 0,
            "crb_report_type": '',
            "used_credit_limit": false,
            "loan_application_status": 'loan_disbursed',
            "credit_limit_status": '',
            "created_at": '2020-10-05T08:38:39.287Z',
            "updated_at": '2020-10-05T08:52:02.796Z',
            "musoni_loan_id": '',
            "max_limit": 0,
            "assignee": '',
            "cold_call": false,
            "musoni_outstanding_balance": '',
            "credit_option": 0,
            "referral_source": 'website',
            "musoni_outstanding_principal": 0,
            "approval_type": '',
            "approval_date": '',
            "limit_activated_at": '',
            "customer_id": '09386b7e-1ccb-4f8c-beb8-13f479a9b73a',
            "id": '4d9536fe-16d6-4833-9565-1e9b7d21cfeb',
            "initial_principal_amount": 144_126,
            "interest_rate": 4,
            "loan_duration": 4,
            "accepted_terms": true,
            "loan_product_id": 'c947ae5b-b6d7-4fd0-9fea-857a62d68008',
            "disbursed_at": '',
            "expected_disbursal_date": '',
            "credit_limit_description": ''
          },
          "credit_limit_detail": {
            "id": '31ff4005-97d4-41ea-8951-de665ff356e6',
            "available_limit": 303_086,
            "credit_limit": 93_226,
            "credit_score_report": 'deliquency_report',
            "credit_score_notes": '',
            "credit_limit_status": 'limit_active',
            "credit_option": 'option_1',
            "approval_type": 'auto_approval',
            "customer_id": '09386b7e-1ccb-4f8c-beb8-13f479a9b73a',
            "approved_at": '2020-10-05T08:38:39.266Z',
            "limit_activated_at": '2020-10-05T08:38:39.266Z',
            "deleted_at": '',
            "created_at": '2020-10-05T08:38:39.269Z',
            "updated_at": '2020-10-05T08:38:39.269Z'
          },
          "customer": {
            "provider": 'email',
            "uid": 'cassey@mcclure.com',
            "allow_password_change": false,
            "name": 'Corrinne',
            "nickname": '',
            "image": '',
            "email": 'cassey@mcclure.com',
            "created_at": '2020-10-05T08:38:38.683Z',
            "updated_at": '2020-10-05T08:38:38.683Z',
            "first_name": 'Jamie',
            "last_name": 'Bayer',
            "id_number": '9804194429086',
            "phone_number": '719840515',
            "date_of_birth": '1959-04-11T00:00:00.000Z',
            "marital_status": 'married',
            "gender": 'other',
            "employed": false,
            "musoni_id": '',
            "customer_standing": 'good',
            "status": 0,
            "countries_id": '2b0e3be4-ac32-4b2f-9423-471f032465f6',
            "id": '09386b7e-1ccb-4f8c-beb8-13f479a9b73a',
            "cold_call": false,
            "referral_source": '',
            "assignee": ''
          },
          "partner_store": {
            "store_name": 'Friesen-Keeling',
            "store_location": 'mombasa',
            "store_phone_numbers": '1-835-403-6633 x90162',
            "created_at": '2020-10-05T08:38:38.188Z',
            "updated_at": '2020-10-05T08:38:38.188Z',
            "store_key": @store.store_key,
            "id": '94388f63-b7fd-4be5-819e-13ca24bf339e',
            "partner_id": '42a69a50-a947-44a8-aa0e-7a3c98ec5967',
            "country": ''
          },
          "country": {
            "id": '2b0e3be4-ac32-4b2f-9423-471f032465f6',
            "alpha_2_code": 'KE',
            "calling_code": '254',
            "deleted_at": '',
            "created_at": '2020-10-05T08:38:38.243Z',
            "updated_at": '2020-10-05T08:38:38.243Z'
          }
        }
      ]
    }

    @sales = {
      "facilities": [
        {
          "musoni_loan_id": '4107597',
          "principal_amount": 0,
          "interest_rate": 8,
          "loan_duration": 12,
          "facility_status": 'pending_collection_customer',
          "preferred_option": 'pick_up',
          "facility_description": 'Unde eos sunt. Alias enim fuga.',
          "facility_plan": '',
          "created_at": '2020-10-05T08:38:39.303Z',
          "updated_at": '2020-10-05T09:32:28.011Z',
          "item_type": 'tablet',
          "item_brand": 'ASUS',
          "item_code": '',
          "store_name": '',
          "item_value": 8000,
          "delivery_option": 'customer_store_pickup',
          "item_description": 'ASUS 10inch tablet',
          "accepted_terms": true,
          "item_topup": 0,
          "topup_ref": '',
          "id": 'e1814f76-fdc5-442d-a9a2-47b2559eda9b',
          "loan_application_detail_id": '4d9536fe-16d6-4833-9565-1e9b7d21cfeb',
          "partner_store_id": '94388f63-b7fd-4be5-819e-13ca24bf339e',
          "loan_product_id": '',
          "loan_application_detail": {
            "credit_limit": 0,
            "crb_report_type": '',
            "used_credit_limit": false,
            "loan_application_status": 'loan_disbursed',
            "credit_limit_status": '',
            "created_at": '2020-10-05T08:38:39.287Z',
            "updated_at": '2020-10-05T08:52:02.796Z',
            "musoni_loan_id": '',
            "max_limit": 0,
            "assignee": '',
            "cold_call": false,
            "musoni_outstanding_balance": '',
            "credit_option": 0,
            "referral_source": 'website',
            "musoni_outstanding_principal": 0,
            "approval_type": '',
            "approval_date": '',
            "limit_activated_at": '',
            "customer_id": '09386b7e-1ccb-4f8c-beb8-13f479a9b73a',
            "id": '4d9536fe-16d6-4833-9565-1e9b7d21cfeb',
            "initial_principal_amount": 144_126,
            "interest_rate": 4,
            "loan_duration": 4,
            "accepted_terms": true,
            "loan_product_id": 'c947ae5b-b6d7-4fd0-9fea-857a62d68008',
            "disbursed_at": '',
            "expected_disbursal_date": '',
            "credit_limit_description": ''
          },
          "credit_limit_detail": {
            "id": '31ff4005-97d4-41ea-8951-de665ff356e6',
            "available_limit": 303_086,
            "credit_limit": 93_226,
            "credit_score_report": 'deliquency_report',
            "credit_score_notes": '',
            "credit_limit_status": 'limit_active',
            "credit_option": 'option_1',
            "approval_type": 'auto_approval',
            "customer_id": '09386b7e-1ccb-4f8c-beb8-13f479a9b73a',
            "approved_at": '2020-10-05T08:38:39.266Z',
            "limit_activated_at": '2020-10-05T08:38:39.266Z',
            "deleted_at": '',
            "created_at": '2020-10-05T08:38:39.269Z',
            "updated_at": '2020-10-05T08:38:39.269Z'
          },
          "customer": {
            "provider": 'email',
            "uid": 'cassey@mcclure.com',
            "allow_password_change": false,
            "name": 'Corrinne',
            "nickname": '',
            "image": '',
            "email": 'cassey@mcclure.com',
            "created_at": '2020-10-05T08:38:38.683Z',
            "updated_at": '2020-10-05T08:38:38.683Z',
            "first_name": 'Jamie',
            "last_name": 'Bayer',
            "id_number": '9804194429086',
            "phone_number": '719840515',
            "date_of_birth": '1959-04-11T00:00:00.000Z',
            "marital_status": 'married',
            "gender": 'other',
            "employed": false,
            "musoni_id": '',
            "customer_standing": 'good',
            "status": 0,
            "countries_id": '2b0e3be4-ac32-4b2f-9423-471f032465f6',
            "id": '09386b7e-1ccb-4f8c-beb8-13f479a9b73a',
            "cold_call": false,
            "referral_source": '',
            "assignee": ''
          },
          "partner_store": {
            "store_name": 'Friesen-Keeling',
            "store_location": 'mombasa',
            "store_phone_numbers": '1-835-403-6633 x90162',
            "created_at": '2020-10-05T08:38:38.188Z',
            "updated_at": '2020-10-05T08:38:38.188Z',
            "store_key": @store.store_key,
            "id": '94388f63-b7fd-4be5-819e-13ca24bf339e',
            "partner_id": '42a69a50-a947-44a8-aa0e-7a3c98ec5967',
            "country": ''
          },
          "country": {
            "id": '2b0e3be4-ac32-4b2f-9423-471f032465f6',
            "alpha_2_code": 'KE',
            "calling_code": '254',
            "deleted_at": '',
            "created_at": '2020-10-05T08:38:38.243Z',
            "updated_at": '2020-10-05T08:38:38.243Z'
          }
        }
      ]
    }

    post :auto_release, params: @sales1, as: :json
  end

  describe 'POST create sale' do
    context 'with valid params' do
      it 'successfully creates a sale on hub' do
        post :auto_release, params: @sales, as: :json
        expect(response).to be_successful
        b = JSON.parse(response.body)
        p b
        expect(b['status']).to eq('Success')
        expect(b['message']).to eq('Items saved successfully')
      end
    end
  end
  describe 'POST create sale' do
    context 'with empty array of facilities' do
      it 'generates empty array response' do
        sales = { "facilities": [] }
        post :auto_release, params: sales, as: :json
        expect(response).to be_successful
        b = JSON.parse(response.body)

        expect(b['status']).to eq('Error')
        expect(b['message']).to eq('Empty array of facilities')
      end
    end
  end
  describe 'POST cancel sales' do
    context 'with valid params' do
      it 'successfully cancels the provided sale by ids on hub' do
        id1 = @sales1[:facilities][1][:id]
        id0 = @sales1[:facilities][0][:id]
        post :cancel_facilities, params: { facility_ids: [id0, id1] }, as: :json
        expect(response).to be_successful
        b = JSON.parse(response.body)
        expect(b['facilities_not_found'].size).to eq(0)
        expect(b['facilities_successfully_cancelled'].size).to eq(2)
      end
    end
  end
end
