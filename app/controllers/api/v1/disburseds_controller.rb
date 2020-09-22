# frozen_string_literal: true

class Api::V1::DisbursedsController < Api::DisbursedController
  require 'sendgrid-ruby'
  require 'text-table'
  include SendGrid

  def auto_release
    saved_released_items = permitted_params[:facilities]
    received_sales = []
    principal = 0
    rate = 4.2
    duration = 12
    # p saved_released_items
    # p params
    p '************************ Released Items  *********************************'
    p saved_released_items
    unless saved_released_items.present?
      Rails.logger.info 'We received an emty array of items for auto release'
      render json: { status: 'Success', message: 'No Items posted ' }, status: :ok
    end
    saved_released_items.each_with_index do |item, index|
      p "************************ ITEM: #{index} *********************************"
      p item
      item = JSON.parse(item)
      # p item
      # p item.to_json
      customer = item['customer']
      country = item['country']
      credit_limit_detail= item['credit_limit_detail']
      customer_limit = credit_limit_detail['available_limit']
      store = item['partner_store']['store_key']
      p customer
      external_id = item['id']
      new_sale = Sale.new
      new_sale.external_id = external_id
      # new_sale.id_number = id_number
      new_sale.buying_price = item['item_value'].to_f
      new_sale.item = item['item_type']
      new_sale.item_type = item['item_brand']
      new_sale.item_description = item['item_description']
      new_sale.store = store
      new_sale.source_id = store
      new_sale.released_item_id = item['id']
      new_sale.customer_names = customer['first_name'] + ' ' + customer['last_name']
      new_sale.customer_email = customer['email']
      new_sale.customer_phone_number = customer['phone_number'][-9..-1] || customer['phone_number']
      new_sale.customer_id_number = customer['id_number']
      new_sale.pick_up_type = item['delivery_option']
      new_sale.pick_up_option = item['preferred_option']
      new_sale.item_code = item['item_code']
      new_sale.item_topup_amount = item['item_topup']
      new_sale.item_topup_ref = item['topup_ref']
      new_sale.customer_limit = customer_limit
      new_sale.customer_country = country['alpha_2_code']
      # new_sale.save!
      if new_sale.save
        puts '-------------------------------------------------------------------------------------------------------------------'
        msg = "We have saved a new sale from core with the following details #{permitted_params}"
        puts msg
        puts '-------------------------------------------------------------------------------------------------------------------'

        SendNotificationToSlackWorker.perform_async(msg)

        # logic to notify partner and team of new release
        current_store = Store.find_by(source_id: store)

        if current_store.nil?
          # could not find store
          subject = "Release to unknown store #{store}"
          msg = "We have received a new sale on The Hub, but the attached store key: #{store} does not exist on The Hub."
          tos = ['wnzisa@lipalater.com', 'ekaguima@lipalater.com']
          ccs = ['mmaina@odysseyafricapital.com', 'disbursed@lipalater.com', 'disbursed@lipalater.com.test-google-a.com',
                 'hzare@lipalater.com', 'tech@lipalater.com', 'dorare@lipalater.com']
          email_payload = {
            'subject' => subject,
            'message' => msg,
            'to' => tos.join(','),
            'cc' => ccs.join(','),
            'from' => 'theHub@lipalater.com',
            'purpose' => 'general'
          }
          NotificationMailerWorker.perform_async(email_payload)

          next
        end
        received_sales << new_sale
      else
        puts '-----------------------------------------'
        puts "Could not save sale with external id: #{external_id}"
        puts new_sale.errors.full_messages
        puts '-----------------------------------------'
      end
      principal += item['item_value'].to_f
      rate = item['interest_rate'].to_f
      duration = item['loan_duration'].to_i
      # customer_release_email(new_sale, item['item_value'], item['interest_rate'], item['loan_duration'])

      p "************************ ITEM: #{index}  saved id: *********************************"
      # send_customer_email
    end
    store_release_email(received_sales)
    customer_release_email(received_sales, principal, rate, duration)
    render json: { status: 'Success', message: 'Items saved successfully' }, status: :ok
  end

  def customer_release_email(sales, principal_amount, rate, duration)
    sale = sales[0]
    from = 'contracts@lipalater.com'
    tos = [sale.customer_email]
    bccs = ['disbursed@lipalater.com', 'disbursed@lipalater.com.test-google-a.com', 'tkivite@lipalater.com', 'hzare@lipalater.com', 'dorare@lipalater.com', 'customers@lipalater.com']
    subject = 'Your Lipa Later Facility Details'
    email_payload = {}
    email_payload['to'] = tos.join(',')
    email_payload['bcc'] = bccs.join(',')
    email_payload['subject'] = subject
    email_payload['from'] = from
    email_payload['purpose'] = 'items'
    item_payload = []
    msg = ''

    store = sale.store
    item_type = sale.item
    pick_up_option = sale.pick_up_option
    pick_up_type = sale.pick_up_type
    # Get delivery details
    delivery_details = ' '
    msg += "#{sale.customer_names}, below are the terms and conditions that you agreed to and signed off on.
           We are currently processing your item(s) and we will be in touch with you to schedule delivery/collection."
    if pick_up_option == 'delivery'
      delivery_details += 'We will reach out to you soon to schedule the delivery/collection of your item(s)'
    elsif pick_up_option == 'pick_up' && (pick_up_type == 'customer_store_pickup' || pick_up_type == 'store_pick_up')
      # attempt to get location of store
      current_store = Store.find_by(source_id: store)
      store_name = if !current_store.nil? && !current_store.location.nil?
                     current_store.location
                   else
                     store
                   end
      delivery_details = "We will reach out to you to schedule collection of your item(s) at our partner store : #{store_name}"
    elsif pick_up_option == 'pickup' && pick_up_type == 'customer_storepickup'
      # attempt to get location of store
      current_store = Store.find_by(source_id: store)
      store_name = if !current_store.nil? && !current_store.location.nil?
                     current_store.location
                   else
                     store
                   end
      delivery_details = "We will reach out to you to schedule collection of your item(s) at our partner store : #{store_name}"
    else
      delivery_details = 'You can now pick your item(s) at our offices located along Ngong Lane on Ngong Road, Daykio Plaza office suite 1.2 between 9am and 5pm.'
    end

    # Generate item hash
    sales.each do |this_sale|
      items_hash = { 'item_type' => this_sale.item,
                     'items_brand' => this_sale.item_type,
                     'delivery_details' => delivery_details,
                     'item_description' => this_sale.item_description }
      item_payload << items_hash
    end

    # Add items details and message to email payload

    email_payload['item_details'] = item_payload.to_json
    email_payload['message'] = msg

    # Calculate start and end dates
    today = Time.now.strftime('%d-%m-%Y').to_s
    start_date = DateTime.parse(today.to_time.strftime('%d/%m/%Y').to_s)
                         .next_month(1)
                         .to_time.strftime('%d/%m/%Y').to_s
    end_date = DateTime.parse(start_date.to_time.strftime('%d/%m/%Y').to_s)
                       .next_month(duration.to_i)
                       .to_time.strftime('%d/%m/%Y').to_s

    # Calclate insurance
    insurance = principal_amount * 5 / 100
    insurance = 1500 if insurance < 1500
    insurance_instructions = ''
    insurance_instructions = if item_type == 'furniture'
                               "Upfront fees of #{insurance} to be paid with first month's installment"
                             else
                               "Insurance of #{insurance} to be paid with first month's installment"
                             end

    # Create account details
    account_payload = {

      'amount' => principal_amount,
      # ([principal * [1 + rate%]) / 12
      'installment' => format('%.2f', (principal_amount.to_f * (1 + rate * 12 / 100)) / 12),
      'loan_term' => duration,
      'interest_rate' => rate,
      'payment_start_date' => start_date,
      'late_payment_penalty' => '1500',
      'payment_end_date' => end_date,
      'insurance' => insurance,
      'insurance_instructions' => insurance_instructions

    }
    # Add account details to payload
    email_payload['account_details'] = account_payload
    puts 'Sending customer email with the following payload'
    puts email_payload.inspect
    # Call email worker
    NotificationMailerWorker.perform_async(email_payload)
  end

  def store_release_email(sales)
    # current_store = sale.store

    sale = sales[0]
    sales_grouped_by_store = sales.group_by { |i| i['store'] }
    item_details = []
    sales_grouped_by_store.each do |key, value|
      item_details[0] = ['Store', 'Item Details', 'Item Price', 'To be picked by']
      # table = '<table><thead><tr><th>Store</th><th>Item Details</th><th>Item Price</th><th>To be picked by</th></tr></thead><tbody>'
      item_data = ''
      p "preparing email for store: #{key}"
      p 'Value'
      p value

      value.each_with_index do |sale, index|
        sale_data = []
        # p index
        sale_data << sale.store
        sale_data << "#{sale.item_type} #{sale.item_description}"
        sale_data << sale.buying_price
        pick_up_by = sale.pick_up_option == 'pick_up' && (sale.pick_up_type == 'customer_store_pickup' || sale.pick_up_type == 'customer_storepickup' || sale.pick_up_type == 'store_pick_up') ? "#{sale.customer_names} ID NUMBER: - #{sale.customer_id_number}" : 'Jonathan Kamondoi ID NUMBER: - 23792784'
        sale_data << pick_up_by
        item_details << sale_data
        # item_data += "<tr><td>#{sale.store}</td><td>#{sale.item_type} #{sale.item_description}</td><td>#{sale.buying_price}</td><td>#{pick_up_by}</td></tr>"
        item_data += "\n\nITEM #{index + 1} "
        item_data += "\n----------------------------------------------------------------- "

        item_data += "\n ITEM           :- #{sale.item_type} #{sale.item_description}"
        item_data += "\n STORE          :- #{sale.store}"
        item_data += "\n AMOUNT         :- #{sale.buying_price}"
        item_data += "\n TO BE PICKE BY :- #{pick_up_by}"
      end
      # table = '</tbody></table'

      current_store = Store.find_by(source_id: key)
      # item_brand = sale.item_type
      # item_description = sale.item_description
      # buying_price = sale.buying_price
      # pick_up_option = sale.pick_up_option
      # pick_up_type = sale.pick_up_type

      account_manager_email = 'wnzisa@lipalater.com'
      partner = Partner.find_by(id: current_store.partner_id)
      account_manager = User.find_by(id: partner.account_manager)

      account_manager_email = account_manager.email if !account_manager.nil? && !account_manager.email.nil?

      subject = "ITEMS FOR RELEASE - #{current_store.source_id.upcase} (#{Time.now.strftime('%d/%m/%Y')})"
      tos = [current_store.disburse_email]
      # ccs = ['mmaina@odysseyafricapital.com']
      ccs = ['tkivite@gmail.com']
      ccs << current_store.disburse_email_cc1.split(',') unless current_store.disburse_email_cc1.nil?
      # ccs.push('tkivite@gmail.com')
      # bccs = []
      # ccs.push(')
      bccs = ['disbursed@lipalater.com', 'disbursed@lipalater.com.test-google-a.com', 'hzare@lipalater.com',
              'customers@lipalater.com', 'romwodo@lipalater.com']
      bccs.push(account_manager_email)

      store_msg = 'Kindly note that the following items will be collected from your store'
      store_msg += "\n CUSTOMER NAME      :- #{sale.customer_names}"
      store_msg += "\n CUSTOMER ID NUMBER :- #{sale.customer_id_number}"
      store_msg += "\n MOBILE             :- #{sale.customer_phone_number}"
      store_msg += "\n\n RELEASED ITEMS  "
      store_msg += "\n______________________________________"

      store_msg += item_data     
      puts '***Sending Partner Email'
      email_payload = {
        'subject' => subject,
        'message' => store_msg,
        'to' => tos.join(','),
        'from' => 'theHub@lipalater.com',
        'cc' => ccs.join(','),
        'bcc' => bccs.join(','),
        'purpose' => 'general'

      }
      puts email_payload.inspect
      NotificationMailerWorker.perform_async(email_payload)
    end
  end

  def cancel_facilities
    puts '-------------------------------------------------------------------------------------------------------------------'
    msg = 'We have received a request to cancel facilities'
    puts msg
    puts '-------------------------------------------------------------------------------------------------------------------'

    saved_released_items = permitted_params[:facility_ids]

    p '************************ Items to Cancel  *********************************'
    p saved_released_items

    not_found = []
    updated = []
    errors = []
    collected = []

    saved_released_items.each_with_index do |item, _count|
      item_external_id = item
      sale = Sale.find_by(external_id: item_external_id)
      if sale.nil?
        not_found << item
        # Skip iteration

      elsif sale.status == 'pending'
        # insert into cancelled
        new_cancel = CancelledSale.new(customer_names: sale.customer_names, customer_phone_number: sale.customer_phone_number,
                                       customer_email: sale.customer_email, customer_id_number: sale.customer_id_number,
                                       buying_price: sale.buying_price, approved_amount: sale.buying_price, approved_monthly_installment: sale.approved_monthly_installment,
                                       repayment_period: sale.repayment_period, interest_rate: sale.interest_rate,
                                       payment_start_date: sale.payment_start_date,
                                       item_type: sale.item_type, item_description: sale.item_description,
                                       store: sale.store, pick_up_option: sale.pick_up_option, pick_up_type: sale.pick_up_type,
                                       source_id: sale.store, status: 'pending', external_id: sale.external_id)
        if new_cancel.save
          sale.destroy
          # sale.status = 'Cancelled'
          # sale.save!
          # store = sale.store
          msg = "We have just CANCELLED a sale for #{sale.store}, Facility Id:  #{item_external_id}"
          puts msg
          puts '-------------------------------------------------------------------------------------------------------------------'
          SendNotificationToSlackWorker.perform_async(msg)

          store_msg = 'Kindly note that the following sale has been CANCELLED '
          store_msg += "\n NAME      :- #{sale.customer_names}"
          store_msg += "\n ID NUMBER :- #{sale.customer_id_number}"
          store_msg += "\n ITEM      :- #{sale.item_type}"
          store_msg += "\n STORE      :- #{sale.store}"
          store_msg += "\n MOBILE    :- +#{sale.customer_phone_number}"
          store_msg += "\n AMOUNT    :- #{sale.buying_price}"

          sale_store = Store.find_by(source_id: sale.source_id)

          partner = Partner.find_by(id: sale_store.partner_id)
          account_manager = User.find_by(id: partner.account_manager)
          account_manager_email = 'tkivite@lipalater.com'
          account_manager_email = account_manager.email unless account_manager.nil? || account_manager.email.nil?

          to = [sale_store.manager_email, sale_store.disburse_email, sale_store.disburse_email_cc1,
                'mmaina@odysseyafricapital.com', 'disbursed@lipalater.com', 'disbursed@lipalater.com.test-google-a.com', 'customers@lipalater.com', account_manager_email]

          from = 'accounts@lipalater.com'
          begin
            puts "sending email to: #{to}   from: #{from}  msg: #{store_msg}"
            email_payload = {
              'subject' => "Sale Cancellation - #{sale_store.source_id.upcase} (#{Time.now.strftime('%d/%m/%Y')})",
              'message' => store_msg,
              'to' => to.join(','),
              'from' => from,
              'purpose' => 'general'

            }
            NotificationMailerWorker.perform_async(email_payload)
          rescue StandardError => e
            puts '------------------------------------------'
            msg = "An error occurred while sending  sale cancellation email to #{to} with the message : #{e.inspect} Error Backtrace: #{e.backtrace}"
            puts msg
            puts '------------------------------------------'
            SendNotificationToSlackWorker.perform_async(msg)
            # render json: {error: ['Problems Occurred trying to send email.']}, status: :created
            # return
          end

          updated << item

        else
          errors << item
          msg = "We were NOT ABLE TO CANCEL the sale for #{store},  #{item_external_id}"
          puts msg
          puts '-------------------------------------------------------------------------------------------------------------------'
          SendNotificationToSlackWorker.perform_async(msg)

        end

      else
        collected << item
        msg = "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!\n"
        msg += "ATTEMPT TO CANCEL an item that has been collected #{item_external_id} \n"
        msg += '!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! \n'
        puts msg
        puts '-------------------------------------------------------------------------------------------------------------------'
        SendNotificationToSlackWorker.perform_async(msg)
      end
    end
    puts '-------------------------------------------------------------------------------------------------------------------'
    msg = "We have received a request to CANCEL facilities from core with the following details #{permitted_params}"
    puts msg
    puts '-------------------------------------------------------------------------------------------------------------------'
    SendNotificationToSlackWorker.perform_async(msg)
    render json: { facilities_successfully_cancelled: updated, facilities_already_collected: collected, facilities_not_found: not_found, facilities_failed: errors }, status: :ok
  end

  def permitted_params
    params
    # permited = params.permit(:facilities,:disbursed, :external_id, :app_store, :customer_names, :customer_email, :customer_phone_number,
    #                          :customer_id_number, :approved_monthly_installment, :interest_rate, :payment_start_date, :repayment_period,
    #                          :sales_agent, :approved_amount, :decision, :decision_reason, facilities:[],pick_up_option: [], pick_up_type: [], buying_price: [], item_type: [],
    #                                                                                       item_brand: [], item_description: [], store: [], item_id: [])
  end
end
