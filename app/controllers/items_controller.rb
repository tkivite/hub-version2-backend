# frozen_string_literal: true

class ItemsController < ApplicationController  
  include CanonicalRequestHelper
  require 'json'

  def fetch_client
    sale = Sale.new
    authorize sale, :view? 
    parameters = {
      id_number: params[:idNumber],
      store: params[:store_key]
    }
    response = prepare_canonical_request('POST', 'fetch_client', parameters)
    response = ActiveSupport::JSON.decode(response.body)
    render json: { status: response['status'], description: response['description'], payload: response['payload'] }, status: :ok
  end

  def save_facilities
    # Function to store items that the client has selected at store    
    sale = Sale.new
    authorize sale, :create? 
    id_number = params[:idNumber]
    parameters = {
      loan_app_id: params[:completeAppId],
      id_number: id_number,
      total_amount: params[:totalAmount],
      store_key: params[:store],
      released_items: params[:items],
      customer_limit: params[:customerLimit],
      topup_amount: params[:customerTopupAmount],
      topup_ref: params[:customerTopupRef]

    }
    # store = current_user.store.source_id

    # 1.1 Save items on core
    response = prepare_canonical_request('POST', 'save_client_facilities', parameters)
    response = ActiveSupport::JSON.decode(response.body)

    begin
      # response = response.body
      if response.nil?
        render json: { status: false, description: 'No response from server' }, status: :ok
        return
      end
      unless response.nil?
        if response['status'] == true
          render json: { status: response['status'], description: response['description'] }, status: :ok
          return
        else
          render json: { status: response['status'], description: response['description'] }, status: :ok
          return
        end
      end

      #  2 Return result to front-end
      render json: { status: response['status'], description: response['description'] }, status: :ok
      nil
    rescue RestClient::ExceptionWithResponse => e
      p '/***********************************************************************************\\'
      p ' -------------------------------- HTTP POST CALL ERROR ------------------------------- '
      p e.response
      p '\***********************************************************************************/'
      # Return Error
      e.response
    end
  end
end
