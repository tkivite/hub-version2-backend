# frozen_string_literal: false

class CollectionsController < ApplicationController

    before_action :set_collection, only: %i[show update destroy]
  
    include CanonicalRequestHelper
  
    # GET /collections
    def index    
      collections = Collection.all
      collections_filtered = collections.paginate(page: params[:page], per_page: 25)
      total_records = collections.count
      render json: { collections: collections_filtered, total_records: total_records }, status: :ok
    end
  
    # GET /collections/1
    def show
      render json: @collection
    end
  
    # POST /collections
    def create
      @collection = Collection.new(collection_params)
  
      if @collection.save
        render json: @collection, status: :created, location: @collection
      else
        render json: @collection.errors, status: :unprocessable_entity
      end
    end
  
    # PATCH/PUT /collections/1
    def update
      if @collection.update(collection_params)
        render json: @collection
      else
        render json: @collection.errors, status: :unprocessable_entity
      end
    end
  
    # DELETE /collections/1
    def destroy
      @collection.destroy
    end
  
    # Initiate Pick up /collections/pickup
    def customer_store_pickup
      customer_id_number = params[:id_number]
      # store = params[:store]
      store = current_user.store.source_id
      puts "store: #{store}"
  
      @sales = Sale.where(customer_id_number: customer_id_number, store: store, status: 'pending').where.not(item_type: 'to be added').order(created_at: :desc)
  
      @sales.where('pick_up_type = ? OR pick_up_type = ?', 'store_pick_up', 'customer_store_pickup')
      if @sales.nil? || @sales.empty?
        # render json: { error: 'No pending items for that id number' }
        render json: { sales: @sales, msg: 'No pending items for that id number' }, status: :no_content
        return
      end
  
      parameters = {
        id_number:customer_id_number,
        store: store
      } 
      phone_number = @sales.first.formatted_phone_number
      customer_name = @sales.first.customer_names
      generated_pin = generate_varification_pin(6)
      verification_pin = VerificationCode.new(code: generated_pin, requested_at: Time.now, customer_id_number: customer_id_number)
  
      if verification_pin.save!
        # send sms here
        puts '------------------------------------------'
        one_time_pin_msg = "Your verification code to collect your Lipa Later Item is: #{generated_pin}. Your friends at Lipa Later."
        puts "Verification code sent to: #{customer_name} #{phone_number} #{customer_id_number} #{one_time_pin_msg}"
        puts '------------------------------------------'
        SendSmsWorker.perform_async(phone_number, 'Lipalater', one_time_pin_msg)
        # json_response(true, :created)
      else
        render json: { error: 'Unable to save pin' }
        return
      end
  
      render json: { sales: @sales, mobile: phone_number, msg: 'We have some items for this id number' }, status: :ok
    end
  
    def lipalater_store_pickup
      customer_id_number = params[:id_number]
      # store = params[:store]
      store = current_user.store.source_id
      puts "store: #{store}"
  
      # check id number is a lipalater user
      #
      #
      user = User.where(id_number: customer_id_number, active_status: true, role: 'Lipalater_delivery').first
  
      if user.nil?
        # render json: { error: 'id number is not for a valid lipalater pick up staff' }
        render json: { user: user, msg: 'id number is not for a valid lipalater pick up staff' }, status: :not_found
        return
      end
  
      @sales = Sale.where(store: store, status: 'pending').where.not(pick_up_type: 'store_pick_up').order(created_at: :desc)
  
      puts "sales: #{@sales}"
  
      if @sales.nil? || @sales.empty?
        # render json: { error: 'No pending items for that id number' }
        render json: { sales: @sales, msg: 'No pending items for that id number' }, status: :no_content
        return
      end
      phone_number = user.formatted_phone_number
      customer_name = user.firstname
      generated_pin = generate_varification_pin(6)
      verification_pin = VerificationCode.new(code: generated_pin, requested_at: Time.now, customer_id_number: customer_id_number)
  
      if verification_pin.save!
        # send sms here
        puts '------------------------------------------'
        one_time_pin_msg = "Your verification code to collect Items  is: #{generated_pin}. Your friends at Lipa Later."
        # puts one_time_pin_msg
        puts "Verification code sent to: #{customer_name} #{phone_number} #{customer_id_number} #{one_time_pin_msg}"
        puts '------------------------------------------'
        SendSmsWorker.perform_async(phone_number, 'Lipalater', one_time_pin_msg)
        # json_response(true, :created)
      else
        render json: { error: 'Unable to save pin' }
        return
      end
  
      render json: { sales: @sales, user: user, mobile: phone_number, msg: 'We have some items for this id number' }, status: :ok
    end
    def external_agent_store_pickup
        customer_id_number = params[:id_number]
        # store = params[:store]
        store = current_user.store.source_id
        puts "store: #{store}"
    
        # check id number is a lipalater user
        #
        #
        user = User.where(id_number: customer_id_number, active_status: true, role: 'Delivery_agent').first
    
        if user.nil?
          # render json: { error: 'id number is not for a valid lipalater pick up staff' }
          render json: { user: user, msg: 'id number is not for a valid delivery agent' }, status: :not_found
          return
        end
    
        @sales = Sale.where(store: store, status: 'pending').where.not(pick_up_type: 'delivery').order(created_at: :desc)
    
        puts "sales: #{@sales}"
    
        if @sales.nil? || @sales.empty?
          # render json: { error: 'No pending items for that id number' }
          render json: { sales: @sales, msg: 'No pending items for that id number' }, status: :no_content
          return
        end
        phone_number = user.formatted_phone_number
        customer_name = user.firstname
        generated_pin = generate_varification_pin(6)
        verification_pin = VerificationCode.new(code: generated_pin, requested_at: Time.now, customer_id_number: customer_id_number)
    
        if verification_pin.save!
          # send sms here
          puts '------------------------------------------'
          one_time_pin_msg = "Your verification code to collect Items  is: #{generated_pin}. Your friends at Lipa Later."
          # puts one_time_pin_msg
          puts "Verification code sent to: #{customer_name} #{phone_number} #{customer_id_number} #{one_time_pin_msg}"
          puts '------------------------------------------'
          SendSmsWorker.perform_async(phone_number, 'Lipalater', one_time_pin_msg)
          # json_response(true, :created)
        else
          render json: { error: 'Unable to save pin' }
          return
        end
    
        render json: { sales: @sales, user: user, mobile: phone_number, msg: 'We have some items for this id number' }, status: :ok
      end
  
  
    
      def complete_pickup
      id_number = params[:id_number]
      verification_pin = params[:verification_code]
      selected_items = params[:selected_items]
      pickup_notes = params[:pickup_notes]
      item_code = params[:item_code]
      pickup_type = params[:pickup_type]
      collected_by_name = params[:collected_by_name]
      #collected_by_customer, collected_lipalater,collected_by_external_agent,collected_by_store_agent
      new_status = params[:status]
  
      puts "Items #{selected_items}"
      puts "Codes #{item_code}"
  
      if id_number.nil?
        # check pin
        return render json: { error: 'Id number not present' }, status: :error
      end
      if verification_pin.nil?
        # check pin
        return render json: { error: 'Verification code not present' }, status: :error
      end
  
      if selected_items.empty?
        # check pin
        return render json: { error: 'You have not provided items' }, status: :error
      end
  
      # if pickup_type == 'customer'
  
      verification_code = VerificationCode.where(verified: false, customer_id_number: id_number).order(created_at: :desc).first
      if verification_code.nil?
        # check pin
        return render json: { error: 'Verification code not present, Try generate a new one' }, status: :error
      end
  
      puts '--------------------------------------------------'
      puts verification_code.customer_id_number
      puts '--------------------------------------------------'
      # puts verification_code.validate(verification_pin)
      puts '--------------------------------------------------'
  
      puts verification_pin.to_s
  
      if verification_code.validate(verification_pin)
  
        verification_code.verified = true
        verification_code.save!
        # create collections for each item
        # send emails
        # update core backend
        #
  
        # sales = selected items
        # selected_items.each do |sel_item|
        selected_item_external_ids = []
        selected_sales = []
        selected_items.each_with_index do |sel_item, count|
          puts "Sale: #{sel_item}"
          sale = Sale.find_by(id: sel_item)
          item_cd = item_code[count]
  
          puts "---Item Code #{item_cd}"
  
          # item_details = sale.item_type + '' +sale.item + sale.item_description
  
          # sales = Sale.where(customer_id_number: id_number, pick_up_type: 'store_pick_up', store: store, status: 'pending').order(created_at: :desc)
  
          # sales.each do |sale|
          Collection.create!(sales_id: sale.id, customer_names: sale.customer_names, customer_phone_number: sale.customer_phone_number, customer_id_number: sale.customer_id_number,
                             item: sale.item_description, store: sale.store, collected_by_name: collected_by_name, collected_by_id_number: id_number, verification_code: verification_pin, status: new_status, item_code: item_cd,
                             collection_notes: pickup_notes, user_id: current_user.id)
  
          sale.collected_at = Time.now
          sale.status = new_status
          if sale.save!
            puts "Updated sale as #{new_status} for #{sale.id}"
            # slack
          end
          # do we still need
  
          puts 'sending pickup email to stake holders'
          puts 'sending pickup email to lipalater '
          msg = 'Dear Lipalater,'
          msg += "\n\n\t This is to inform you that an item has been collected at #{sale.store}"
          msg += "\n\n\t Item:- #{sale.item_description}"
          msg += "\n\n\t Collected By Name:- #{collected_by_name}"
          msg += "\n\n\t Collected By Id:- #{id_number}"
          msg += "\n\n\t Store:- #{sale.store}"
          msg += "\n\n\t"
          tos = ['tkivite@lipalater.com', 'hzare@lipalater.com', 'delivery@lipalater.com',
                 'dorare@lipalater.com', 'romwodo@lipalater.com']
          ccs = []
          begin
            puts "sending email #{tos}  the message is:  #{msg}"
            email_payload = {
              'subject' => 'The hub - An Item has been collected',
              'message' => msg,
              'to' => tos.join(','),
              'from' => 'theHub@lipalater.com',
              'purpose' => 'general'
            }
            NotificationMailerWorker.perform_async(email_payload)
          rescue StandardError => e
            puts '------------------------------------------'
            msg = "An error occurred while sending pickup email to #{tos}  : #{e.inspect} Error Backtrace: #{e.backtrace}"
            puts msg
            puts '------------------------------------------'
            SendNotificationToSlackWorker.perform_async(msg)
            render json: { error: ['Problems Occured trying to send email.'] }, status: :not_found
          end
          if sale.created_at > Date.new(2020, 6, 12)
            selected_item_external_ids << sale.external_id
            selected_sales << sale
          end
          if sale.created_at < Date.new(2020, 6, 13)
            manual_process_notification(sale)
          end
  
          puts '--------------------Updating core ---------------------'
          # UpdatePickupWorker.perform_async(sale.external_id.first(-2), sale.released_item_id)
        end
        unless selected_item_external_ids.empty?
          if pickup_type =='lipalater'
            p "This is a lipalater pick. Let's group by client"
            sales_grouped_by_client = selected_sales.group_by {|i| i['customer_id_number'] }
            sales_grouped_by_client.each do |key, value|
              p "posting items for #{key}"
              item_ids = value.map {|item| item['external_id']}
              UpdatePickupWorker.perform_async(item_ids)
            end
          else  
           UpdatePickupWorker.perform_async(selected_item_external_ids)
          end
        end
  
        render json: { msg: ['Validation Successful !.'] }, status: :ok
        nil
      else
        render json: { error: ['Validation Failed !.'] }, status: :not_found
        nil
      end
    end
    def store_agent_store_pickup
        customer_id_number = params[:id_number]
        # store = params[:store]
        store = current_user.store.source_id
        puts "store: #{store}"
    
        # check id number is a lipalater user
        #
        #
        user = User.where(id_number: customer_id_number, active_status: true, role: 'Delivery_agent').first
    
        if user.nil?
          # render json: { error: 'id number is not for a valid lipalater pick up staff' }
          render json: { user: user, msg: 'id number is not for a valid delivery agent' }, status: :not_found
          return
        end
    
        @sales = Sale.where(store: store, status: 'pending').where.not(pick_up_type: 'delivery').order(created_at: :desc)
    
        puts "sales: #{@sales}"
    
        if @sales.nil? || @sales.empty?
          # render json: { error: 'No pending items for that id number' }
          render json: { sales: @sales, msg: 'No pending items for that id number' }, status: :no_content
          return
        end
        phone_number = user.formatted_phone_number
        customer_name = user.firstname
        generated_pin = generate_varification_pin(6)
        verification_pin = VerificationCode.new(code: generated_pin, requested_at: Time.now, customer_id_number: customer_id_number)
    
        if verification_pin.save!
          # send sms here
          puts '------------------------------------------'
          one_time_pin_msg = "Your verification code to collect Items  is: #{generated_pin}. Your friends at Lipa Later."
          # puts one_time_pin_msg
          puts "Verification code sent to: #{customer_name} #{phone_number} #{customer_id_number} #{one_time_pin_msg}"
          puts '------------------------------------------'
          SendSmsWorker.perform_async(phone_number, 'Lipalater', one_time_pin_msg)
          # json_response(true, :created)
        else
          render json: { error: 'Unable to save pin' }
          return
        end
    
        render json: { sales: @sales, user: user, mobile: phone_number, msg: 'We have some items for this id number' }, status: :ok
      end
  
  
    
    def complete_manual_pickup
      selected_items = params[:selected_items]
  
      item_code = params[:item_code]
      item_notes = params[:item_notes]
      item_reason = params[:item_reason]
  
      puts "Codes #{item_code}"
  
      if selected_items.empty?
        # check pin
        return render json: { error: 'You have not provided items' }, status: :error
      end
  
      # item_cd = item_code[count]
      # puts "--------------------Updating core ---------------------"
      # UpdatePickupWorker.perform_async(sale.external_id)
      selected_items&.each_with_index do |sel_item, count|
        puts "Sale: #{sel_item}"
        sale = Sale.find_by(id: sel_item)
        # item_cd = item_code[count]
        pickup_notes = item_notes[count]
        reason = item_reason[count]
  
        if sale
          Collection.create!(sales_id: sale.id, customer_names: sale.customer_names, customer_phone_number: sale.customer_phone_number, customer_id_number: sale.customer_id_number,
                             item: sale.item_description, store: sale.store, collected_by_name: current_user.firstname + '' + current_user.lastname, collected_by_id_number: current_user.id_number, verification_code: 'none', status: reason,
                             collection_notes: pickup_notes, user_id: current_user.id)
          sale.collected_at = Time.now
          sale.status = reason
          if sale.save!
            puts "Updated sale as #{reason} for #{sale.id}"
          else
            puts sale.errors.full_messages
          end
        end
  
        puts 'sending update email to lipalater '
  
        msg = 'Dear Lipalater,'
        msg += "\n\n\t This is to inform you that an item has been manually updated"
        msg += "\n\n\t Item:- #{sale.item_description}"
        msg += "\n\n\t Collected By Name:- #{current_user.firstname}  #{current_user.lastname}"
        msg += "\n\n\t Collected By Id:- #{current_user.id_number}"
        msg += "\n\n\t Store:- #{sale.store}"
        msg += "\n\n\t"
        to = ['tkivite@gmail.com', 'hzare@lipalater.com', 'delivery@lipalater.com',
              'dorare@lipalater.com', 'romwodo@lipalater.com']
        from = 'thehub@lipalater.com'
        begin
          puts "sending email #{to}   #{from} #{msg}"
          email_payload = {
            'subject' => 'The hub - An Item status has been updated',
            'message' => msg,
            'to' => to.join(','),
            'from' => from,
            'purpose' => 'general'
  
          }
          NotificationMailerWorker.perform_async(email_payload)
        rescue StandardError => e
          puts '------------------------------------------'
          msg = "An error occurred while sending pickup email to #{to}  : #{e.inspect} Error Backtrace: #{e.backtrace}"
          puts msg
          puts '------------------------------------------'
          SendNotificationToSlackWorker.perform_async(msg)
          render json: { error: ['Problems Occured trying to send email.'] }, status: :not_found
          return
        end
  
        if reason == 'collected'
          puts '--------------------Updating core ---------------------'
          if sale.created_at > Date.new(2020, 6, 12)
            UpdatePickupWorker.perform_async([sale.external_id])
          end
          if sale.created_at < Date.new(2020, 6, 13)
            manual_process_notification(sale)
          end
  
        end
      end
  
      render json: { msg: ['Pickup Successful !.'] }, status: :ok
    end
  
    def update_collected_item_price
      # Function to update adjusted amount for collected items
      # @param collection_id String
      # @param utilized_amount String
      # @param adjusted_amount String
      # @param store_name String
      # @param authorized_by String
      # @param authorized_by_email String
  
      collection_id = params[:collection_id]
      utilized_amount = params[:utilized_amount]
      adjusted_amount = params[:adjusted_amount]
      store_name = params[:store_name]
      authorized_by = params[:authorized_by]
      authorized_by_email = params[:authorized_by_email]
      credit_limit_change = utilized_amount - adjusted_amount
  
      # Finalize on data sources
      payload = {
        previous_total: utilized_amount,
        new_total: adjusted_amount,
        cerdit_limit_change: credit_limit_change,
        complete_app_id: nil,
        store_name: store_name,
        authorized_by: authorized_by,
        authorized_by_email: authorized_by_email,
        partner_portal_ref_id: nil
      }
  
      # Step 1 : Update collection record
      collection = Collection.find_by(id: collection_id)
  
      if collection.present?
        collection.update_attributes
        sale = Sale.find_by(id: collection.sale_id)
        payload[:complete_app_id] = sale.external_id
      else
        # Raise error if record not found
        return render json: { status: 'Failed to save' }, status: :not_modified
      end
  
      # Step 2.1 : Create a balance log record
      balance_log = BalanceLog.new
      balance_log.previous_collections_id = collection.id
      balance_log.new_collections_id = new_collection.id
      balance_log.sales_id = new_collection.sales.id
      balance_log.user_id = params[:user_id]
      balance_log.previous_total = utilized_amount
      balance_log.new_total = adjusted_amount
  
      begin
        balance_log.save
      rescue StandardError => e
        Rails.logger.error 'Failed to save trail of total amount update  => ' + e.inspect
        # Return Error
        return render json: { status: 'Failed to save' }, status: :not_modified
      end
  
      # Step 3: Update Core
      response = prepare_canonical_request('post', 'api/v1/update_loan_value', payload)
  
      case response.status
      when 200
        render json: { status: response.status, description: 'Record has been updated' }, status: :ok
        Rails.logger.error ' Message from Core : 200 Ok => ' + response.body
  
      when 404
        Rails.logger.error ' Message from Core : 404 Not Found => ' + response.body
        render json: { status: response.status, description: 'Unable to process request at this moment' }, status: :not_found
  
      when 500
        render json: { status: response.status, description: 'Unable to process request at this moment' }, status: :internal_server_error
        Rails.logger.error ' Message from Core : 500 Internal Server Error => ' + response.body
  
      else
        render json: { status: response.status, description: 'Unable to process request at this moment' }, status: :internal_server_error
        Rails.logger.error ' Message from Core : Unclassified Error => ' + response.body
      end
    end
  
    private
  
    # Use callbacks to share common setup or constraints between actions.
    def set_collection
      @collection = Collection.find(params[:id])
    end
  
    # Only allow a trusted parameter "white list" through.
    def collection_params
      params.permit(:sales_id, :customer_names, :customer_phone_number, :customer_id_number, :item, :verification_code, :collected_by_id_number, :collected_by_name, :item_code, :receipt, :collection_notes)
    end
  
    def generate_varification_pin(size = 6)
      charset = %w[0 1 2 3 4 6 7 9]
      pin = (0...size).map { charset.to_a[SecureRandom.random_number(charset.size)] }.join
      pin
    end
  
    def manual_process_notification(sale)
      msg = "The following client has collected an item that was released earlier than June 13th 2020.\n"
      msg.force_encoding('UTF-8')
      msg.concat("Unfortunately these pickups do not trigger auto creation of musoni loans.\n")
      msg.concat("Kindly review the details and ensure the loan is booked and disbursed.\n")
      msg.concat("Find facility details below: \n\n")
      msg.concat("Customer Infor: \n")
      msg.concat("---------------------------------------------------------------------------  \n\n")
      msg.concat("Names: #{sale.customer_names} \n")
      msg.concat("Email: #{sale.customer_email} \n")
      msg.concat("Id Number: #{sale.customer_id_number} \n")
      msg.concat("Mobile:  #{sale.customer_phone_number} \n\n")
      msg.concat("Musoni Loan Booking Infor:   \n")
      msg.concat("---------------------------------------------------------------------------  \n\n")
      msg.concat("Principal: #{sale.buying_price} \n")
      msg.concat("Topup Amount: #{sale.item_topup_amount}\n")
      msg.concat("Topup Ref: #{sale.item_topup_ref}\n")
      msg.concat("Interest: #{sale.interest_rate}\n")
      msg.concat("Duration: #{sale.repayment_period}\n")
      msg.concat("Installments: #{sale.approved_monthly_installment}\n")
      msg.concat("RepaymentStart Date: #{sale.payment_start_date}\n\n")
  
      msg.concat("Facility Details: (Items Data)  \n")
      msg.concat("---------------------------------------------------------------------------  \n\n")
  
      items_record = {
        "store": sale.store,
        "price": sale.buying_price.to_s,
        "topup_amount": sale.item_topup_amount.to_s,
        "topup_ref": sale.item_topup_ref.to_s,
        "item_type": sale.item_type,
        "item_brand": sale.item,
        "item_description": sale.item_description || '',
        "item_code": sale.item_code
      }
  
      msg.concat("Items_data:   #{items_record.flatten} \n")
  
      Rails.logger.error 'An old item has been collected'
      Rails.logger.error 'Sending Email'
      Rails.logger.error msg
      # 'to' => 'bmaranga@lipalater.com ,tkivite@lipalater.com,pkariuki@lipalater.com,mmaina@odysseyafricapital.com,gkamau@liapalater.com,lodhiambo@lipalater.com',
  
      email_payload = {
        'to' => 'bmaranga@lipalater.com ,tkivite@lipalater.com,hzare@lipalater.com,romwodo@lipalater.com,pkariuki@lipalater.com,mmaina@odysseyafricapital.com,gkamau@lipalater.com,lodhiambo@lipalater.com',
        'from' => 'hub@lipalater.com',
        'message' => msg,
        'subject' => 'Pickup Requiring Manual Creation on Musoni',
        'purpose' => 'general'
      }
      NotificationMailerWorker.perform_async(email_payload)
    end
  end
  