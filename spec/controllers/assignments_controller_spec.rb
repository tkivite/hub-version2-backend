# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AssignmentsController, type: :controller do
  before(:each) do
    # Accepted a permissions
    @permissions = %w[assignment:create assignment:update assignment:show assignment:list]
    # Disallowed
    @d_permissions = %w[create:role update:role]
    # Create role
    @role = FactoryBot.create(:role)
    # Create user
    @user = FactoryBot.create(:user)
    @role.permissions = @permissions
    @user.roles << @role
    request.headers['Authorization'] = @user.authorization_token
  end

  describe 'POST create assignment' do
    context 'with valid params' do
      it 'successfully creates an assignment' do
        p = { user_id: @user.id,
              role_id: @role.id }
        post :create, params: p, as: :json
        expect(response).to be_successful
        b = JSON.parse(response.body)
        # p b
        expect(b['id']).to_not eq(nil)
        expect(b['user_id']).to eq(@user.id)
        expect(b['role_id']).to eq(@role.id)
        # expect(b['description']).to eq('success')
      end
    end

    context 'with invalid params' do
      it 'return error message' do
        p = { user_id: 'id',
              role_id: 'id' }
        post :create, params: p, as: :json
        expect(response).to_not be_successful
        b = JSON.parse response.body
        # p b
        expect(b['id']).to eq(nil)
        expect(b['user_id']).to_not eq(@user.id)
        expect(b['role_id']).to_not eq(@role.id)
      end
    end
  end

  describe 'GET #index' do
    context 'with valid params' do
      it 'returns all assignments' do
        get :index
        expect(response).to be_successful
      end
    end
  end

  describe 'GET show' do
    context 'with valid params' do
      it 'successfully returns a created assignment' do
        # Create a  new assignment with valid params
        assignment = FactoryBot.create(:assignment, user: @user, role: @role)
        response = get :show, params: { id: assignment.id }
        expect(response).to be_successful
        expect(response).to have_http_status(:ok)
      end
    end
    context 'with invalid params' do
      it 'throws an error message' do
        response =  get :show, params: { id: 'uSeLess_String_ID' }
        expect(response).to have_http_status(:not_found)
        # expect(response.body.downcase).to eq('No assignment info found'.downcase)
      end
    end
  end
end
