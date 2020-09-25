# frozen_string_literal: true

class ContactsController < ApplicationController
  before_action :set_contact, only: %i[show update destroy]

  # GET /contacts
  def index
    # searchKey = params[:searchkey].upcase
    authorize Contact.first, :list? unless Contact.first.nil?
    contacts = Contact.all
    policy_scope contacts
    render json: { contacts: contacts, total_records: contacts.count }, status: :ok
  end

  # POST /contacts
  def create
    Rails.logger.info "Received request to create contact: #{contact_params}"
    @contact = Contact.new(contact_params)
    authorize @contact, :create?
    @contact.save
    json_response(@contact, :created)
  end

  # GET /contacts/:id
  def show
    authorize @contact, :show?
    @contacts = Contact.where(record_id: params[:id])
    json_response(@contacts)
  end

  # PUT /contacts/:id
  def update
    authorize @contact, :update?
    @contact.update!(contact_params)
    json_response(@contact, :ok)
  end

  # DELETE /contacts/:id
  def destroy
    @contact.destroy
    @contacts = Contact.all
    json_response(@contacts)
  end

  private

  def contact_params
    # whitelist params
    params.permit(:type, :title, :name, :email, :mobile, :extra_details,
                  :record_id)
  end

  def set_contact
    @contact = contact.find(params[:id])
  end
end
