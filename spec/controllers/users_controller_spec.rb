# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  before(:each) do
    # Accepted a permissions
    @permissions = %w[user:create user:update user:view user:list  user:destroy]
    # Disallowed
    @d_permissions = %w[create:role update:role]
    # Create role
    @role = FactoryBot.create(:role)
    # Create user
    @logged_in_user = FactoryBot.create(:user)
    @a_user = FactoryBot.create(:user1)
    @role.permissions = @permissions
    @logged_in_user.roles << @role
    @user = FactoryBot.create(:user2)
    @user.created_by = @logged_in_user.id
    lipalater_core_base_url = ENV['LIPALATER_CORE_BASE_URL']    
    lipalater_core_base_url = (lipalater_core_base_url[-1] == "/")? lipalater_core_base_url : lipalater_core_base_url + "/"

   
    @valid_params = {
        firstname: 'demo3',
        othernames: 'use3r',
        gender: 'Male',
        email: 'demouser31@demo.test',
        password: 'password',
        mobile: '0725475056',
        created_by: @logged_in_user.id,
    }
   
    @invalid_params = {
        myname: "Test"
    }
    request.headers['Authorization'] =@logged_in_user.authorization_token
  end

  describe 'POST create user' do
    context 'with valid params' do
      it 'successfully creates a user' do
        post :create, params: @valid_params, as: :json
        expect(response).to be_successful
        b = JSON.parse(response.body)
        expect(response).to have_http_status(201)
         p b
        expect(b['id']).to_not eq(nil)
        expect(b['created_by']).to eq(@logged_in_user.id)
        expect(b['status']).to eq('pending')
        expect(b['firstname']).to eq('demo3')
        expect(b['email']).to eq('demouser31@demo.test')
        expect(b['mobile']).to eq('0725475056')
      end
    end

    context 'with invalid params' do
      it 'return error message' do
        
        post :create, params: @invalid_params, as: :json
        expect(response).to_not be_successful
        expect(response).to have_http_status(422)
        b = JSON.parse response.body
        expect(b['id']).to eq(nil)
      end
    end
    context 'with wrong permissions' do
      it 'return not allowed message' do
        @role.permissions = ''
        @logged_in_user.roles = []
        @role.permissions = @d_permissions
        @logged_in_user.roles << @role
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
      it 'returns all users' do
        get :index
        expect(response).to be_successful
        expect(response).to have_http_status(200)
      end
      context 'with wrong permissions' do
        it 'return not allowed message' do
          @role.permissions = ''
          @logged_in_user.roles = []
          @role.permissions = @d_permissions
          @logged_in_user.roles << @role
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
      it 'successfully returns the created user' do               
        get :show, params: { id: @user.id }
        expect(response).to be_successful
        expect(response).to have_http_status(:ok)
      end
    end
    context 'with invalid params' do
      it 'throws an error message' do
        get :show, params: { id: 'uSeLess_String_ID' }
        expect(response).to have_http_status(:not_found)
      end
    end
    context 'with wrong permissions' do
      it 'return not allowed message' do
        @role.permissions = ''
        @logged_in_user.roles = []
        @role.permissions = @d_permissions
        @logged_in_user.roles << @role
        
        response = get :show, params: { id: @user.id }
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
         
        put :update, params: { id: @user.id,created_by: @a_user.id,
          firstname: 'updatedfirstname',othernames:'updated_name',email:'changedemail@email.mail' }
      end       


      it 'updates the record' do
        
        expect(response).to be_successful
        b = JSON.parse response.body
        expect(b['id']).to eq(@user.id)
        expect(b['created_by']).to eq(@a_user.id)
        expect(b['firstname']).to eq('updatedfirstname') 
        expect(b['email']).to eq('changedemail@email.mail')
        expect(b['othernames']).to eq('updated_name')
        expect(response).to have_http_status(200)
      end
     
    end
    context 'with invalid params' do
      before (:each) do
            
         
        put :update, params: { id: 'nothing',created_by: @a_user.id,
            firstname: 'updatedfirstname',lastname:'updated_name',email:'changedemail@email.mail' }
      end  
      it 'throws an error message' do
        expect(response).to have_http_status(:not_found)
        # expect(response.body.downcase).to eq('No user info found'.downcase)
      end
    end
    context 'with wrong permissions' do
      before (:each) do
        @role.permissions = ''
        @logged_in_user.roles = []
        @role.permissions = @d_permissions
        @logged_in_user.roles << @role          
         
       put :update, params: { id: @user.id,created_by: @a_user.id,
        firstname: 'updatedfirstname',lastname:'updated_name',email:'changedemail@email.mail' }
      end  
      it 'return not allowed message' do        
        expect(response).to have_http_status(403)
        expect(response).to_not be_successful
        b = JSON.parse response.body
        expect(b['message']).to eq('You are not allowed to perform this action')        
      end
    end
  end


  describe 'DELETE #delete' do   

    context 'with valid params' do
      
      before (:each) do            
         
        delete :destroy, params: { id: @user.id }
      end   
      


      it 'deletes the record' do
        
        expect(response).to be_successful
        b = JSON.parse response.body
        expect(response).to have_http_status(200)
      end
     
    end
    context 'with invalid params' do
      before (:each) do
        
        delete :destroy, params: { id: "ridiculous" }
      end  
      it 'throws an error message' do
        expect(response).to have_http_status(:not_found)
      end
    end
    context 'with wrong permissions' do
      before (:each) do
        @role.permissions = ''
       @logged_in_user.roles = []
        @role.permissions = @d_permissions
       @logged_in_user.roles << @role  
         
        delete :destroy, params: { id: @user.id }
      end  
      it 'return not allowed message' do
        
        expect(response).to have_http_status(403)
        expect(response).to_not be_successful
        b = JSON.parse response.body
        expect(b['message']).to eq('You are not allowed to perform this action')        
      end
    end
  end
end
