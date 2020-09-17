# frozen_string_literal: true

include CanonicalRequestHelper
class StoresController < ApplicationController
  before_action :set_store, only: %i[show update destroy]

  # GET /stores
  def index
    # searchKey = params[:searchkey].upcase
    dataparams = JSON.parse params[:dataparams]
    puts "Data Params: #{dataparams}"
    search_key = dataparams['searchKey'].upcase
    page = dataparams['page']
    stores = Store.where("concat_ws(' ' , UPPER(name),UPPER(store_key)) LIKE ?", "%#{search_key}%").order(created_at: :desc)
    stores_filtered = stores.paginate(page: page, per_page: 25)
    render json: { stores: stores_filtered.to_json(include: { partner: { only: :name } }), total_records: stores.count }, status: :ok
  end

  def lipalater
    dataparams = JSON.parse params[:dataparams]
    Rails.logger.info "Fetching lipalater Data Params: #{dataparams}"
    search_key = dataparams['searchKey'].upcase
    stores = Store.where("partner_id in (select id from partners where name::varchar like ?) and concat_ws(' ' , UPPER(name),UPPER(store_key)) LIKE ?", '%ipalater%', "%#{search_key}%").order(created_at: :desc)
    stores_filtered = stores.paginate(page: params[:page], per_page: 25)
    render json: { stores: stores_filtered.to_json(include: { partner: { only: :name } }), total_records: stores.count }, status: :ok
  end

  def stores
    # dataparams = JSON.parse params[:dataparams]
    stores = Store.all
    render json: { stores: stores.to_json(include: { partner: { only: :name } }), total_records: stores.count }, status: :ok
  end

  # POST /stores
  def create
    Rails.logger.info "Received request to create store: #{store_params}"
    @user = current_user
    @store = Store.new(store_params)
    partner = Partner.find_by(id: @store.partner_id)
    postdata = {
      name: @store.name,
      location: @store.location,
      manager_phone: @store.manager_phone,
      store_code: @store.store_key,
      country: @store.country,
      partner_core_id: partner.core_id
    }
    response = prepare_canonical_request('POST', 'create_store', postdata.as_json)
    response = ActiveSupport::JSON.decode(response.body)
    json_response({ status: false, description: 'could not create on core' }, :error) unless response['status'] == true
    @store.update_attribute(core_id, response['record_id'])
    partner = Partner.find_by(id: @store.partner_id)
    account_manager = User.find_by(id: partner.account_manager)
    account_manager_email =  account_manager.nil? || account_manager.email.nil? ? 'tkivite@lipalater.com' : account_manager.email
    msg = "\n\n\t This is to let you know that a new store has been created with the following details:"
    msg += "\n\n\t Store Name:- #{@store.name}"
    msg += "\n\n\t Store Key:- #{@store.source_id}"
    msg += "\n\n\t Partner:- #{partner.name}"
    msg += "\n\n\t Created  by:- #{@user.firstname} #{@user.lastname}"
    msg += "\n\n\t"
    msg += "\n\n\t If this email was sent by mistake kindly ignore"
    msg += "\n\n\t Should you have challenges or need our assistance feel free to call us on: 0709684000"
    to = [account_manager_email, 'tkivite@gmail.com', 'tkivite@lipalater.com', 'mmwaniki@lipalater.com', 'pwamburu@lipalater.com', 'dorare@lipalater.com', 'mmaina@odysseyafricapital.com']
    from = 'thehub@lipalater.com'

    begin
      puts "sending email to: #{to}   from: #{from}  msg: #{msg}"
      email_payload = {
        'subject' => "The hub - We have onboarded a new store:  #{@store.name}",
        'message' => msg,
        'to' => to.join(','),
        'from' => from,
        'purpose' => 'general'

      }
      NotificationMailerWorker.perform_async(email_payload)
    rescue StandardError => e
      puts '------------------------------------------'
      msg = "An error occurred while sending user creation email to #{to} with the message : #{e.inspect} Error Backtrace: #{e.backtrace}"
      puts msg
      puts '------------------------------------------'
      SendNotificationToSlackWorker.perform_async(msg)
      # render json: {error: ['Problems Occurred trying to send email.']}, status: :created
      return
    end

    json_response(@store, :created)
  end

  # GET /stores/:id
  def show
    json_response(@store)
  end

  # PUT /stores/:id
  def update
    @store.update!(store_params)
    partner = Partner.find_by(id: @store.partner_id)
    postdata = {
      core_id: @store.core_id,
      name: @store.name,
      location: @store.location,
      manager_phone: @store.manager_phone,
      store_code: @store.store_code,
      partner_core_id: partner.core_id
    }
    response = prepare_canonical_request('PUT', 'update_store', postdata.as_json)
    p response
    response = ActiveSupport::JSON.decode(response.body)
    if response['status'] == true
      message = 'We have just updated a store on core v2'
      p message
      SendNotificationToSlackWorker.perform_async(message)
      json_response(@store, :ok)
    else
      p 'We faced problems while updating a store to core v2'
      # json_response(@store, :ok)
      json_response({ status: false, description: 'could not update on core' }, :error)
    end
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
end
