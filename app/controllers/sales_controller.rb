class SalesController < ApplicationController

  def index


    puts "#{params}"

    dataparams = JSON.parse params[:dataparams]
    puts "Data Params: #{dataparams}"
    action = dataparams["action"].upcase

    puts "Action = DOwnload: #{action}"
    puts  action == "download"
    puts  action == 'download'

    if (action == 'DOWNLOAD')
      store = ''
      unless ((current_user.role).downcase == 'lipalater admin' || (current_user.role).downcase == 'lipalater super admin')
        store = current_user.store.source_id
      end
      SalesDownloadWorker.perform_async(dataparams,'',current_user.email,store)
     # render json: {msg: 'We have received your request'}, status: :ok
    end
      search_key = dataparams["searchKey"].upcase
      puts "search key: #{search_key}"
      start_date = dataparams["startdate"]
      end_date = dataparams["enddate"]
      page = dataparams["page"]

      sales = Sale.where("concat_ws(' ' , UPPER(customer_names), customer_phone_number,UPPER(customer_id_number),UPPER(item_description),UPPER(store)) LIKE ?", "%#{search_key}%").order(created_at: :desc)
      sales = sales.where(:created_at => (start_date.to_time - 1.day)..(end_date.to_time + 2.day))
      total_records = sales.count

      unless ((current_user.role).downcase == 'lipalater admin' || (current_user.role).downcase == 'lipalater super admin')
        puts "------#{current_user.store.source_id}"
        sales = sales.where(source_id: current_user.store.source_id)
        total_records = sales.count
      end
      sales_filtered = sales.paginate(page: page, per_page: 25)
      render json: {sales: sales_filtered, total_records: total_records}, status: :ok




  end

  def pending

    #searchKey = params[:searchkey].upcase
    dataparams = JSON.parse params[:dataparams]
    puts "Data Params: #{dataparams}"
    page = dataparams["page"]

    search_key = dataparams["searchKey"].upcase

    puts "search key: #{search_key}"
    start_date = dataparams["startdate"]
    end_date = dataparams["enddate"]
    action = dataparams["action"].upcase


    if (action == 'DOWNLOAD')
      puts "downloading"
      store = ''
      unless ((current_user.role).downcase == 'lipalater admin' || (current_user.role).downcase == 'lipalater super admin')
        store = current_user.store.source_id
      end
      SalesDownloadWorker.perform_async(dataparams,'pending',current_user.email,store)
    end


    sales_init = Sale.where("concat_ws(' ' , UPPER(customer_names), customer_phone_number,UPPER(customer_id_number),UPPER(item_description),UPPER(store)) LIKE ?", "%#{search_key}%").order(created_at: :desc)
    sales = sales_init.where(status: 'pending')
    sales = sales.where(:created_at => (start_date.to_time - 1.day)..(end_date.to_time + 2.day))
    total_records = sales.count

    unless ((current_user.role).downcase == 'lipalater admin' || (current_user.role).downcase == 'lipalater super admin')
      puts "------#{current_user.store.source_id}"
      sales = sales.where(source_id: current_user.store.source_id)
      total_records = sales.count
    end
    sales_filtered = sales.paginate(page: page, per_page: 25)
    render json: {sales: sales_filtered, total_records: total_records}, status: :ok
  end

  def allpending

    dataparams = JSON.parse params[:dataparams]
    page = 1
    search_key = dataparams["searchKey"].upcase


    sales_init = Sale.where("concat_ws(' ' , UPPER(customer_names), customer_phone_number,UPPER(customer_id_number),UPPER(item_description),UPPER(store)) LIKE ?", "%#{search_key}%").order(created_at: :desc)
    sales = sales_init.where(status: 'pending')
    total_records = sales.count
    unless ((current_user.role).downcase == 'lipalater admin' || (current_user.role).downcase == 'lipalater super admin')
      puts "------#{current_user.store.source_id}"
      sales = sales.where(source_id: current_user.store.source_id)
      total_records = sales.count
    end
    sales = sales.paginate(page: page, per_page: 25)
    render json: {sales: sales, total_records: total_records}, status: :ok
  end


  def cancelled

    #searchKey = params[:searchkey].upcase
    dataparams = JSON.parse params[:dataparams]
    puts "Data Params: #{dataparams}"
    page = dataparams["page"]

    search_key = dataparams["searchKey"].upcase

    puts "search key: #{search_key}"
    start_date = dataparams["startdate"]
    end_date = dataparams["enddate"]
    action = dataparams["action"].upcase

    if (action == 'DOWNLOAD')
      store = ''
      unless ((current_user.role).downcase == 'lipalater admin' || (current_user.role).downcase == 'lipalater super admin')
        store = current_user.store.source_id
      end
      SalesDownloadWorker.perform_async(dataparams,'cancelled',current_user.email,store)
    end


    sales_init = CancelledSale.where("concat_ws(' ' , UPPER(customer_names), customer_phone_number,UPPER(customer_id_number),UPPER(item_description),UPPER(store)) LIKE ?", "%#{search_key}%").order(created_at: :desc)
    #sales = sales_init.where(status: 'cancelled')
    sales = sales_init.where(:created_at => (start_date.to_time - 1.day)..(end_date.to_time + 2.day))
    total_records = sales.count

    unless ((current_user.role).downcase == 'lipalater admin' || (current_user.role).downcase == 'lipalater super admin')
      puts "------#{current_user.store.source_id}"
      sales = sales.where(source_id: current_user.store.source_id)
      total_records = sales.count
    end
    sales_filtered = sales.paginate(page: page, per_page: 25)
    render json: {sales: sales_filtered, total_records: total_records}, status: :ok
  end

  def collections

    #searchKey = params[:searchkey].upcase
    dataparams = JSON.parse params[:dataparams]
    puts "Data Params: #{dataparams}"
    action = dataparams["action"].upcase
    page = dataparams["page"]


    if (action == 'DOWNLOAD')
      store = ''
      unless ((current_user.role).downcase == 'lipalater admin' || (current_user.role).downcase == 'lipalater super admin')
        store = current_user.store.source_id
      end
      SalesDownloadWorker.perform_async(dataparams,'collected',current_user.email,store)
    end

      search_key = dataparams["searchKey"].upcase
      puts "search key: #{search_key}"
      start_date = dataparams["startdate"]
      end_date = dataparams["enddate"]
      page = dataparams["page"]

      collection_init = Collection.where("concat_ws(' ' , UPPER(customer_names), customer_phone_number,UPPER(customer_id_number),UPPER(item),UPPER(store)) LIKE ?", "%#{search_key}%").order(created_at: :desc)
      collections = collection_init.where(status: 'collected')
      collections = collections.where(:created_at => (start_date.to_time - 1.day)..(end_date.to_time + 2.day))
      total_records = collections.count
      unless ((current_user.role).downcase == 'lipalater admin' || (current_user.role).downcase == 'lipalater super admin')
        puts "------#{current_user.store.source_id}"
        collections = collections.where(store: current_user.store.source_id)
        total_records = collections.count
      end
      collections_filtered = collections.paginate(page: page, per_page: 25)
      render json: {sales: collections_filtered.to_json(:include => {:sale => {:only => [:approved_amount, :buying_price]}}), total_records: total_records}, status: :ok

  end

  def fetchapps
    # AppsDownloadingWorker.perform_async()
    # render json: {status: 'ok',msg: 'We have received your request'}, status: :ok
    #This can eventually go to a separate worker as above

    api_key = ENV['LIPALATER_CORE_API_KEY']
    api_secret = ENV['LIPALATER_CORE_API_SECRET']
    lipalater_core_base_url = ENV['LIPALATER_CORE_BASE_URL']
    timestamp = Time.now().iso8601
    #store_name = "jkiarie"
    request_method = "GET"
    request_string = "/api/v1/all_disbursed"
    request_params = ""

    puts "connection"
    puts ActiveRecord::Base.configurations[Rails.env]
    # The request string we want to hash
    request_string1 = "#{request_method}\n#{request_string}\n#{request_params}\nApiKey=#{api_key}\nTimestamp=#{timestamp}\n"

    # Create an HMAC
    hmac = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), api_secret, request_string1)
    # Base 64 encode the HMAC
    base64_signature = Base64.encode64(hmac)
    # Remove whitespace, new lines and trailing equal
    base64_signature = base64_signature.strip().chomp("=")


    Rails.logger.info "Canonical Request String: #{request_string1}"
    Rails.logger.info "API Seceret: #{api_secret}"
    Rails.logger.info "Computed Signature: #{base64_signature}"

    begin

      response = RestClient.get "#{lipalater_core_base_url}#{request_string}",
                                {content_type: :json, accept: :json, 'X-Authorization-Signature': "#{base64_signature}",
                                 'X-Authorization-Timestamp': "#{timestamp}", 'Authorization': "LIPALATER-HMAC-SHA256", 'X-Authorization-ApiKey': "#{api_key}"}
      puts "----------------------------------------"
      #puts "The response when fetching partners from core using canonical request: #{response}"
      puts "----------------------------------------"
      records = JSON.parse (response.body)

      puts "----------------------------------------"
      puts "The response size when fetching partners from core using canonical request: #{records.size}"
      puts "----------------------------------------"
      #data = JSON.parse body
      puts "The response body when fetching partners from core using canonical request: #{records}"

      #@apps = data

      if records.size == 0
        puts "----------------------------------------------------"
        puts "Fetch apps from core found 0 records"
        puts "----------------------------------------------------"
        SendNotificationToSlackWorker.perform_async("Checking apps found 0 records. There are no newly released items from core")
      else
        #Loop records saving in database
        app_num = 0
        records.each_with_index do |row, app_num|
          puts "-------------------------------------------------------------------------------------------------------------------"
          # Call a different process
          puts "processing row number #{app_num} Details: #{row}"
          customer_names = row['loan_app']['first_name'] + ' ' + row['loan_app']['last_name']
          phone_number = row['loan_app']['phone_number']
          email = row['loan_app']['email']
          id_number = row['loan_app']['id_number']
          pick_up_options = row['loan_app']['pick_up_options']
          delivery_options = row['loan_app']['delivery_options']
          id_number = row['loan_app']['id_number']
          loan_app_id = row['loan_app']['id']

          puts "---#{customer_names} --"

          item_array = row['loan_app']['item_type']
          amount_array = row['amount']
          loan_term_array = row['loan_term']
          interest_rate_array = row['interest_rate']
          buying_price_array = row['buying_price']
          store_array = row['store']
          count = 0

          item_array.each_with_index do |item, count|
            loan_amount = amount_array[count]
            loan_term = loan_term_array[count]
            interest_rate = interest_rate_array[count]
            buying_price = buying_price_array[count]
            store = store_array[count]
            item_type = item_array[count]
            external_id = loan_app_id + '#' + "#{count}"
            Sale.create!(external_id: external_id, customer_names: customer_names, customer_phone_number: phone_number, customer_email: email, customer_id_number: id_number, buying_price: buying_price, approved_amount: loan_amount, item_type: item_type, item_description: item_type, store: store, pick_up_option: pick_up_options, pick_up_type: delivery_options, source_id: store, status: 'pending')

            puts "-------------------------------------------------------------------------------------------------------------------"

          end


        end


      end

    rescue StandardError => e
      puts "----------------------------------------"
      msg = "Error detected when fetching apps from LipaLater Backend. I'm sad!: #{e.inspect} \n #{e.backtrace}"
      puts msg
      puts "------------------------------------------"
      #@apps = '{"data":"Errors"}'
      render json: {status: "false", msg: "Problems accessing LipaLater Backend"}, status: :false
      return
    end
    render json: {status: "ok", msg: "Downloaded #{app_num} records"}, status: :ok

  end

end
