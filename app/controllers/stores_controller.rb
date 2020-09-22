# frozen_string_literal: true

include CanonicalRequestHelper
class StoresController < ApplicationController
  before_action :set_store, only: %i[show update destroy]

  # GET /stores
  def index
    # searchKey = params[:searchkey].upcase
    authorize Store.first, :list?   
    dataparams = JSON.parse params[:dataparams]
    puts "Data Params: #{dataparams}"
    search_key = dataparams['searchKey'].upcase
    page = dataparams['page']
    stores = Store.where("concat_ws(' ' , UPPER(name),UPPER(store_key)) LIKE ?", "%#{search_key}%").order(created_at: :desc)
    stores_filtered = stores.paginate(page: page, per_page: 25)
    policy_scope stores
    render json: { stores: stores_filtered.as_json(include: { partner: { only: :name } }), total_records: stores.count }, status: :ok
  end

  def lipalater
    authorize Store.first, :list?   
    dataparams = JSON.parse params[:dataparams]
    Rails.logger.info "Fetching lipalater Data Params: #{dataparams}"
    search_key = dataparams['searchKey'].upcase
    stores = Store.where("partner_id in (select id from partners where name::varchar like ?) and concat_ws(' ' , UPPER(name),UPPER(store_key)) LIKE ?", '%ipalater%', "%#{search_key}%").order(created_at: :desc)
    stores_filtered = stores.paginate(page: params[:page], per_page: 25)
    policy_scope stores
    render json: { stores: stores_filtered.to_json(include: { partner: { only: :name } }), total_records: stores.count }, status: :ok
  end

  def stores
    # dataparams = JSON.parse params[:dataparams]
    stores = Store.all
    policy_scope stores
    render json: { stores: stores.to_json(include: { partner: { only: :name } }), total_records: stores.count }, status: :ok
  end

  # POST /stores
  def create
    Rails.logger.info "Received request to create store: #{store_params}"  
    @store = Store.new(store_params)    
    authorize @store, :create? 
    return json_response(@store, :unprocessable_entity) unless @store.valid?
    partner = Partner.find_by(id: @store.partner_id)
    postdata = {
      name: @store.name,
      location: @store.location,
      store_code: @store.store_key,
      country: @store.country,
      partner_core_id: partner.core_id
    }
    response = prepare_canonical_request('POST', 'create_store', postdata.as_json)
    response = ActiveSupport::JSON.decode(response.body)
    json_response({ status: false, description: 'could not create on core' }, :error) unless response['status'] == true
    @store.update_attribute(:core_id, response['record_id'])
    email_payload = generate_email_payload(@store)
    NotificationMailerWorker.perform_async(email_payload)
    json_response(@store, :created)
  end

  # GET /stores/:id
  def show
    authorize @store, :show? 
    json_response(@store)
  end

  # PUT /stores/:id
  def update
    authorize @store, :update? 
    @store.update!(store_params)
    partner = Partner.find_by(id: @store.partner_id)
    postdata = {
      core_id: @store.core_id,
      name: @store.name,
      location: @store.location,
      store_code: @store.store_key,
      partner_core_id: partner.core_id
    }
    response = prepare_canonical_request('PUT', 'update_store', postdata.as_json) 
    response = ActiveSupport::JSON.decode(response.body)
    json_response({ status: false, description: 'could not update on core' }, :error) unless response['status'] == true
    Rails.logger.info "We updated a store on core v2: #{store_params}"  
    json_response(@store, :ok)
  
  end

  # DELETE /stores/:id
  def destroy
    @store.destroy
    @stores = Store.all
    json_response(@stores)
  end

  private

  def store_params
    # whitelist params
    params.permit(:name, :store_key, :location, :target, :partner_id, :no_of_employess,
                  :monthly_revenue, :city, :country)
  end

  def set_store
    @store = Store.find(params[:id])
  end
  def generate_email_payload(store)
    partner = Partner.find_by(id: store.partner_id)
    account_manager = User.find_by(id: partner.account_manager_id)
    account_manager_email =  account_manager.nil? || account_manager.email.nil? ? 'tkivite@lipalater.com' : account_manager.email
    msg = "\n\n\t This is to let you know that a new store has been created with the following details:"
    msg = msg.dup
    msg << "\n\n\t Store Name:- #{store.name}"
    msg << "\n\n\t Store Key:- #{store.store_key}"
    msg << "\n\n\t Partner:- #{partner.name}"
    msg << "\n\n\t Created  by:- #{current_user.firstname} #{current_user.othernames}"
    msg << "\n\n\t"
    msg << "\n\n\t If this email was sent by mistake kindly ignore"
    msg << "\n\n\t Should you have challenges or need our assistance feel free to call us on: 0709684000"
    # to = [account_manager_email, 'tkivite@gmail.com', 'tkivite@lipalater.com', 'mmwaniki@lipalater.com', 'pwamburu@lipalater.com', 'dorare@lipalater.com', 'mmaina@odysseyafricapital.com']
    to = [account_manager_email, 'tkivite@gmail.com', 'tkivite@lipalater.com']

    from = 'thehub@lipalater.com'
    {
      'subject' => "The hub - We have onboarded a new store:  #{store.name}",
      'message' => msg,
      'to' => to.join(','),
      'from' => from,
      'purpose' => 'general'

    }
  end
end
