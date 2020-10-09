# frozen_string_literal: true

require 'rails_helper'

RSpec.describe RolesController, type: :controller do
  before(:each) do
    # Accepted a permissions
    @permissions = %w[role:create role:update role:view role:list role:destroy]
    # Disallowed
    @d_permissions = %w[create:role update:role]
    # Create role
    @login_user_role = FactoryBot.create(:role)
    # Create role
    @logged_in_user = FactoryBot.create(:user)
    @a_user = FactoryBot.create(:user1)
    @login_user_role.permissions = @permissions
    @logged_in_user.roles << @login_user_role
    @role = FactoryBot.create(:role1)
    @role.created_by = @logged_in_user.id

    @valid_params = {
      name: 'demo3',
      permissions: %w[role:show role:create role:update],
      created_by: @logged_in_user.id
    }

    @invalid_params = {
      myname: 'Test'
    }
    request.headers['Authorization'] = @logged_in_user.authorization_token
  end

  describe 'POST create role' do
    context 'with valid params' do
      it 'successfully creates a role' do
        post :create, params: @valid_params, as: :json
        expect(response).to be_successful
        b = JSON.parse(response.body)
        expect(response).to have_http_status(201)
        p b
        expect(b['id']).to_not eq(nil)
        expect(b['created_by']).to eq(@logged_in_user.id)
        expect(b['permissions']).to eq(%w[role:show role:create role:update])
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
        @login_user_role.permissions = ''
        @logged_in_user.roles = []
        @login_user_role.permissions = @d_permissions
        @logged_in_user.roles << @login_user_role
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
          @login_user_role.permissions = ''
          @logged_in_user.roles = []
          @login_user_role.permissions = @d_permissions
          @logged_in_user.roles << @login_user_role
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
      it 'successfully returns the created role' do
        get :show, params: { id: @role.id }
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
        @login_user_role.permissions = ''
        @logged_in_user.roles = []
        @login_user_role.permissions = @d_permissions
        @logged_in_user.roles << @login_user_role

        response = get :show, params: { id: @role.id }
        expect(response).to have_http_status(403)
        expect(response).to_not be_successful
        b = JSON.parse response.body
        expect(b['message']).to eq('You are not allowed to perform this action')
      end
    end
  end

  describe 'PUT #update' do
    context 'with valid params' do
      before(:each) do
        put :update, params: { id: @role.id, created_by: @a_user.id,
                               name: 'updatedname' }
      end

      it 'updates the record' do
        expect(response).to be_successful
        b = JSON.parse response.body
        expect(b['id']).to eq(@role.id)
        expect(b['created_by']).to eq(@a_user.id)
        expect(b['name']).to eq('updatedname')
        expect(response).to have_http_status(200)
      end
    end
    context 'with invalid params' do
      before (:each) do
        put :update, params: { id: 'nothing', created_by: @a_user.id,
                               name: 'updatedname' }
      end
      it 'throws an error message' do
        expect(response).to have_http_status(:not_found)
        # expect(response.body.downcase).to eq('No role info found'.downcase)
      end
    end
    context 'with wrong permissions' do
      before (:each) do
        @login_user_role.permissions = ''
        @logged_in_user.roles = []
        @login_user_role.permissions = @d_permissions
        @logged_in_user.roles << @login_user_role

        put :update, params: { id: @role.id, created_by: @a_user.id,
                               name: 'updatedname' }
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
        delete :destroy, params: { id: @role.id }
      end

      it 'deletes the record' do
        expect(response).to be_successful
        b = JSON.parse response.body
        expect(response).to have_http_status(200)
      end
    end
    context 'with invalid params' do
      before (:each) do
        delete :destroy, params: { id: 'ridiculous' }
      end
      it 'throws an error message' do
        expect(response).to have_http_status(:not_found)
      end
    end
    context 'with wrong permissions' do
      before (:each) do
        @login_user_role.permissions = ''
        @logged_in_user.roles = []
        @login_user_role.permissions = @d_permissions
        @logged_in_user.roles << @login_user_role
        delete :destroy, params: { id: @role.id }
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
