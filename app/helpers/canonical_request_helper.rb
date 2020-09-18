require 'api/h_mac_helper'

module CanonicalRequestHelper
  # Class to handle communication to Lipa Later Backend

  def prepare_canonical_request(request_method, request_url, request_params)
    # Function to generate canonical request for communication with server
    # @param request_method String [get , post, delete]
    # @param request_string String Url to call on Lipa Later Backend
    # @param request_params String Data to pass to backend can be blank for get requests
    unless request_method.blank? || request_url.blank?
      # Initialize
      api_key = ENV['LIPALATER_CORE_API_KEY']
      api_secret = ENV['LIPALATER_CORE_API_SECRET']
      lipalater_core_base_url = ENV['LIPALATER_CORE_BASE_URL']
      timestamp = Time.now.iso8601
      # Rails Environment Params
      p '/***********************************************************************************\\'
      p ' ------------------------------ ENVIRONMENT PARAMETERS ------------------------------ '
      p ActiveRecord::Base.configurations[Rails.env]
      p '\\***********************************************************************************/'

      request_string = HMacHelper.format_request_string(request_method,
                                                        '/'.concat(request_url),
                                                        api_key,
                                                        timestamp,
                                                        request_params)

      p '/***********************************************************************************\\'
      p ' ------------------------------ REQUEST STRING ------------------------------ '
      p request_string
      p '\\***********************************************************************************/'
      # Create an HMAC
      hmac = OpenSSL::HMAC.digest(OpenSSL::Digest.new('sha256'), api_secret, request_string)

      # Base 64 encode the HMAC
      base64_signature = Base64.encode64(hmac)

      # Remove whitespace, new lines and trailing equal
      base64_signature = base64_signature.strip.chomp('=')

      Rails.logger.info "Canonical Request String: #{request_string}"
      Rails.logger.info "API Secret: #{api_secret}"
      Rails.logger.info "Computed Signature: #{base64_signature}"

      lipalater_core_base_url = (lipalater_core_base_url[-1] == "/")? lipalater_core_base_url : lipalater_core_base_url + "/"
      begin
        if request_method.downcase.include?('get')
          begin
            RestClient.get "#{lipalater_core_base_url}#{request_url}",
                           { content_type: :json, accept: :json, 'X-Authorization-Signature': base64_signature.to_s,
                             'X-Authorization-Timestamp': timestamp.to_s, 'Authorization': 'LIPALATER-HMAC-SHA256', 'X-Authorization-ApiKey': api_key.to_s }
          rescue RestClient::ExceptionWithResponse => e
            p '/***********************************************************************************\\'
            p ' ------------------------------- HTTP GET CALL ERROR ------------------------------- '
            p e.response
            p '\***********************************************************************************/'

            # Return Error
            e.response
          end

        elsif  request_method.downcase.include?('post')
          begin
            response = RestClient::Request.execute(method: :post, url: "#{lipalater_core_base_url}#{request_url}", payload: request_params,
                                                   headers: { content_type: :json, accept: :json, 'X-Authorization-Signature': base64_signature.to_s,
                                                              'X-Authorization-Timestamp': timestamp.to_s, 'Authorization': 'LIPALATER-HMAC-SHA256', 'X-Authorization-ApiKey': api_key.to_s })

            # puts "----------------------------------------"
            # # puts "The response when posting request to core is: #{response.body}"
            # puts "----------------------------------------"
            # response_val={}            {"status":false,"description":"Exceeded Credit Limit"}
            # response_val.status = response.body.split(",")[0].split(":")[1]
            # response_val.description = response.body.split(",")[1].split(":")[1]
            #
            response
          rescue RestClient::ExceptionWithResponse => e
            p '/***********************************************************************************\\'
            p ' -------------------------------- HTTP POST CALL ERROR ------------------------------- '
            p e.response
            p '\***********************************************************************************/'

            # Return Error
            e.response
          end

        elsif  request_method.downcase.include?('put')
          begin
            RestClient::Request.execute(method: :put, url: "#{lipalater_core_base_url}#{request_url}", payload: request_params,
                                        headers: { content_type: :json, accept: :json, 'X-Authorization-Signature': base64_signature.to_s,
                                                   'X-Authorization-Timestamp': timestamp.to_s, 'Authorization': 'LIPALATER-HMAC-SHA256', 'X-Authorization-ApiKey': api_key.to_s })
          rescue RestClient::ExceptionWithResponse => e
            p '/***********************************************************************************\\'
            p ' -------------------------------- HTTP PUT CALL ERROR ------------------------------- '
            p e.response
            p '\***********************************************************************************/'

            # Return Error
            e.response
          end

        elsif  request_method.downcase.include?('delete')
          begin
            RestClient::Request.execute(method: :delete, url: "#{lipalater_core_base_url}#{request_url}", payload: request_params,
                                        headers: { content_type: :json, accept: :json, 'X-Authorization-Signature': base64_signature.to_s,
                                                   'X-Authorization-Timestamp': timestamp.to_s, 'Authorization': 'LIPALATER-HMAC-SHA256', 'X-Authorization-ApiKey': api_key.to_s })
          rescue RestClient::ExceptionWithResponse => e
            p '/***********************************************************************************\\'
            p ' ------------------------------- HTTP DELETE CALL ERROR ------------------------------ '
            p e.response
            p '\***********************************************************************************/'

            # Return Error
            e.response
          end
        else
          false
        end
      end
    end
  end

  private

  def serialize_params(params)
    # Function to serialize params
    # @param params Array

    if params.respond_to? :each
      params.each { |key, value| @serialized_params = +"#{key}=#{value}" }
      @serialized_params
    end
  end
end
