# frozen_string_literal: true

class StoreAccountsController < ApplicationController
  before_action :set_store, only: %i[show update destroy]
  def index
    # searchKey = params[:searchkey].upcase
    authorize StoreAccount.first, :list?
    store_accounts = StoreAccount.all
    policy_scope store_accounts
    render json: { store_accounts: store_accounts.as_json(include: { store: { only: :name } }), total_records: store_accounts.count }, status: :ok
  end

  # POST /store_accounts
  def create
    Rails.logger.info "Received request to create Store Account: #{store_account_params}"
    @store_account = StoreAccount.new(store_account_params)
    authorize @store_account, :create?
    json_response(@store_account, :created)
  end

  # GET /store_accounts/:id
  def show
    authorize @StoreAccount, :show?
    json_response(@StoreAccount)
  end

  # PUT /store_accounts/:id
  def update
    authorize @store_account, :update?
    @store_account.update!(store_account_params)
    json_response(@store_account, :ok)
  end

  # DELETE /store_accounts/:id
  def destroy
    @store_account.destroy
    @store_accounts = StoreAccount.all
    json_response(@store_accounts)
  end

  private

  def store_account_params
    # whitelist params
    params.permit(:type, :channel, :account_type, :institution, :account_name, :account_number,
                  :payer_identity, :other_details, :stores_id)
  end

  def set_store_account
    @store_account = StoreAccount.find(params[:id])
  end
end
