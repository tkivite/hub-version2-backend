# frozen_string_literal: true

include CanonicalRequestHelper
class PartnersController < ApplicationController
  before_action :set_partner, only: %i[show update destroy]

  # GET /partners
  def index
    # searchKey = params[:searchkey].upcase
    dataparams = JSON.parse params[:dataparams]
    puts "Data Params: #{dataparams}"
    search_key = dataparams['searchKey'].upcase
    page = dataparams['page']
    # @partners = Partner.all
    partners = Partner.where("concat_ws(' ' , UPPER(name), year_of_incorporation,UPPER(speciality),UPPER(location)) LIKE ?", "%#{search_key}%").order(created_at: :desc)
    partners_filtered = partners.paginate(page: page, per_page: 25)
    total_records = partners.count
    render json: { partners: partners_filtered, total_records: total_records }, status: :ok
  end

  def all_partners
    partners = Partner.all
    total_records = partners.count
    render json: { partners: partners, total_records: total_records }, status: :ok
  end

  # POST /partners
  def create
    Rails.logger.info "Received request to create partner: #{partner_params}"
    @partner = Partner.new(partner_params)
    response = prepare_canonical_request('POST', 'create_partner', @partner.as_json)
    response = ActiveSupport::JSON.decode(response.body)
    json_response({ status: false, description: 'could not create on core' }, :error) unless response['status'] == true
    @partner.update_attribute(core_id, response['record_id'])
    Rails.logger.info 'We have just added a partner to core v2'
    json_response(@partner, :created)
  end

  # GET /partners/:id
  def show
    json_response(@partner)
  end

  # PUT /partners/:id
  def update
    @partner.update!(partner_params)
    response = prepare_canonical_request('PUT', 'update_partner', @partner.as_json)
    response = ActiveSupport::JSON.decode(response.body)
    json_response({ status: false, description: 'could not update on core' }, :error) unless response['status'] == true
    Rails.logger.info 'We have just updated a partner on core v2'
    json_response(@partner, :ok)
  end

  private

  def partner_params
    # whitelist params
    params.permit(:name, :year_of_incorporation, :speciality, :location, :account_manager_id, :creator_id, :no_of_branches, :payment_terms, :credit_duration_in_days)
  end

  def set_partner
    @partner = Partner.find(params[:id])
  end
end
