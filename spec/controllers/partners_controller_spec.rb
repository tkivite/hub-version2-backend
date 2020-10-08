# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PartnersController, type: :controller do
  before(:each) do
    # Accepted a permissions
    @permissions = %w[partner:create partner:update partner:view partner:list  partner:destroy]
    # Disallowed
    @d_permissions = %w[create:role update:role]
    # Create role
    @role = FactoryBot.create(:role)
    # Create user
    @user = FactoryBot.create(:user)
    @a_user = FactoryBot.create(:user1)
    @role.permissions = @permissions
    @user.roles << @role
    @partner = FactoryBot.create(:partner)
    @partner.creator_id = @user.id
    @partner.account_manager_id = @user.id
    lipalater_core_base_url = ENV['LIPALATER_CORE_BASE_URL']    
    lipalater_core_base_url = (lipalater_core_base_url[-1] == "/")? lipalater_core_base_url : lipalater_core_base_url + "/"

    response_data_create = { status: true, description: 'Partner created successfully', record_id: '627ssgd637dhdhdh1io222' }.to_json
    response_data_update = { status: true, description: 'Partner created successfully', record_id: '627ssgd637dhdhdh1io222' }.to_json

    stub_request(:post, "#{lipalater_core_base_url}create_partner").
      to_return({status: "Ok",body:response_data_create.to_s, headers:{}})
      stub_request(:put,"#{lipalater_core_base_url}update_partner").
      to_return({status: "Ok",body:response_data_update.to_s, headers:{}})
    @valid_params = {
        name: "Test", 
        year_of_incorporation:"1982", 
        speciality:"Phones", 
        location:"Nairobi",
        account_manager_id: @user.id, 
        creator_id:@user.id, 
        no_of_branches:2, 
        payment_terms:"credit", 
        credit_duration_in_days:"30"
    }
    @invalid_params = {
        myname: "Test"
    }
    request.headers['Authorization'] = @user.authorization_token
  end

  describe 'POST create partner' do
    context 'with valid params' do
      it 'successfully creates a partner' do
        post :create, params: @valid_params, as: :json
        expect(response).to be_successful
        b = JSON.parse(response.body)
        expect(response).to have_http_status(201)
        # p b
        expect(b['id']).to_not eq(nil)
        expect(b['creator_id']).to eq(@user.id)
        expect(b['account_manager_id']).to eq(@user.id)
        # expect(b['description']).to eq('success')
      end
    end

    context 'with invalid params' do
      it 'return error message' do
        
        post :create, params: @invalid_params, as: :json
        expect(response).to_not be_successful
        b = JSON.parse response.body
        expect(b['id']).to eq(nil)
      end
    end
    context 'with wrong permissions' do
      it 'return not allowed message' do
        @role.permissions = ''
        @user.roles = []
        @role.permissions = @d_permissions
        @user.roles << @role
        post :create, params: @valid_params, as: :json
        expect(response).to have_http_status(403)
        expect(response).to_not be_successful
        b = JSON.parse response.body
        expect(b['message']).to eq('You are not allowed to perform this action')        
      end
    end
  end

  describe 'GET #index' do
    context 'with valid params' do
      it 'returns all partners' do
        get :index
        expect(response).to be_successful
        expect(response).to have_http_status(200)
      end
      context 'with wrong permissions' do
        it 'return not allowed message' do
          @role.permissions = ''
          @user.roles = []
          @role.permissions = @d_permissions
          @user.roles << @role
          get :index
          expect(response).to have_http_status(403)
          expect(response).to_not be_successful
          b = JSON.parse response.body
          expect(b['message']).to eq('You are not allowed to perform this action')        
        end
      end
    end
  end

  describe 'GET show' do
    context 'with valid params' do
      it 'successfully returns the created partner' do
        # Create a  new partner with valid params
        p @partner       
        get :show, params: { id: @partner.id }
        expect(response).to be_successful
        expect(response).to have_http_status(:ok)
      end
    end
    context 'with invalid params' do
      it 'throws an error message' do
        get :show, params: { id: 'uSeLess_String_ID' }
        expect(response).to have_http_status(:not_found)
        # expect(response.body.downcase).to eq('No partner info found'.downcase)
      end
    end
    context 'with wrong permissions' do
      it 'return not allowed message' do
        @role.permissions = ''
        @user.roles = []
        @role.permissions = @d_permissions
        @user.roles << @role
        
        response = get :show, params: { id: @partner.id }
        expect(response).to have_http_status(403)
        expect(response).to_not be_successful
        b = JSON.parse response.body
        expect(b['message']).to eq('You are not allowed to perform this action')        
      end
    end
  end


  describe 'PUT #update' do   

    context 'with valid params' do
      
      before (:each) do            
         
        put :update, params: { id: @partner.id,creator_id: @a_user.id,
          account_manager_id: @a_user.id,name:'updated_name' }
      end       


      it 'updates the record' do
        
        expect(response).to be_successful
        b = JSON.parse response.body
        expect(b['id']).to eq(@partner.id)
        expect(b['creator_id']).to eq(@a_user.id)
        expect(b['account_manager_id']).to eq(@a_user.id) 
        expect(response).to have_http_status(200)
      end
     
    end
    context 'with invalid params' do
      before (:each) do
            
         
        put :update, params: { id: 'nothing',creator_id: @a_user.id,
          account_manager_id: @a_user.id,name:'updated_name' }
      end  
      it 'throws an error message' do
        expect(response).to have_http_status(:not_found)
        # expect(response.body.downcase).to eq('No partner info found'.downcase)
      end
    end
    context 'with wrong permissions' do
      before (:each) do
        @role.permissions = ''
        @user.roles = []
        @role.permissions = @d_permissions
        @user.roles << @role          
         
        put :update, params: { id: @partner.id,creator_id: @a_user.id,
          account_manager_id: @a_user.id,name:'updated_name' }
      end  
      it 'return not allowed message' do        
        expect(response).to have_http_status(403)
        expect(response).to_not be_successful
        b = JSON.parse response.body
        expect(b['message']).to eq('You are not allowed to perform this action')        
      end
    end
  end


  # describe 'DELETE #delete' do   

  #   context 'with valid params' do
      
  #     before (:each) do            
         
  #       delete :destroy, params: { id: @partner.id }
  #     end   
      


  #     it 'deletes the record' do
        
  #       expect(response).to be_successful
  #       b = JSON.parse response.body
  #       expect(response).to have_http_status(200)
  #     end
     
  #   end
  #   context 'with invalid params' do
  #     before (:each) do
        
  #       delete :destroy, params: { id: "ridiculous" }
  #     end  
  #     it 'throws an error message' do
  #       expect(response).to have_http_status(:not_found)
  #     end
  #   end
  #   context 'with wrong permissions' do
  #     before (:each) do
  #       @role.permissions = ''
  #       @user.roles = []
  #       @role.permissions = @d_permissions
  #       @user.roles << @role  
         
  #       delete :destroy, params: { id: @partner.id }
  #     end  
  #     it 'return not allowed message' do
        
  #       expect(response).to have_http_status(403)
  #       expect(response).to_not be_successful
  #       b = JSON.parse response.body
  #       expect(b['message']).to eq('You are not allowed to perform this action')        
  #     end
  #   end
  # end
end
