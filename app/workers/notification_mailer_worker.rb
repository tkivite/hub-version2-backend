# frozen_string_literal: true

class NotificationMailerWorker
  require 'net/http'
  require 'uri'
  require 'json'
  include Sidekiq::Worker
  include AuthenticationHelper

  def perform(payload)
    # return unless Rails.env.production?
    post_uri = ENV['KONG_API'] + '/emails'
    token_url = ENV['KONG_API'] + '/emails/oauth2/token'
    uri = URI.parse(post_uri)
    access_token = AuthenticationHelper.generate_token(token_url)
    request = Net::HTTP::Post.new(uri)
    request['Host'] = ENV['NOTIFICATION_SERVICE_HOST']
    request['Authorization'] = "Bearer #{access_token}"

    # Append bcc emails
    append_bcc_emails(payload)

    h = {}
    payload.each do |k, v|
      h[k] = v
    end

    p h

    request.set_form_data(h)

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    p response.code
    p response.body
  end

  def append_bcc_emails(payload)
    # Function to ppend bcc to each email sent out

    # Initialize variable
    bcc_email = nil

    if payload.key?('bcc')
      bcc_email = payload.try(:[], 'bcc')

      if bcc_email.class == Array
        # Handle if bcc array present (many bcc)
        bcc_email.concat(ENV['BCC_EMAILS_LIST'].split(/\s*,\s*/))
      elsif bcc_email.class == String
        # Handle if bcc array present (single bcc)
        bcc_email = ENV['BCC_EMAILS_LIST'].split(/\s*,\s*/).append(bcc_email)

      elsif bcc_email.class.nil?
        # Handle if bcc present with no value (edge case)
        bcc_email = ENV['BCC_EMAILS_LIST'].split(/\s*,\s*/)
      end
    else
      # Handle if bcc not present in payload
      bcc_email = ENV['BCC_EMAILS_LIST'].split(/\s*,\s*/)
    end

    payload['bcc'] = remove_duplicates(bcc_email)
  end

  def remove_duplicates(list)
    # Function to remove duplicates
    list.to_set.to_a
  end
end
