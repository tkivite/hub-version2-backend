# frozen_string_literal: true

module AuthenticationHelper
  require 'net/http'
  require 'uri'
  require 'openssl'
  require 'json'
  require 'resolv-replace'

  def self.generate_token(url)
    uri = URI.parse(url)
    request = Net::HTTP::Post.new(uri)
    request['Host'] = ENV['NOTIFICATION_SERVICE_HOST']
    request['X-Forwarded-Proto'] = 'https'
    request.set_form_data(
      'client_id' => ENV['NOTIFICATION_CLIENT_ID'],
      'client_secret' => ENV['NOTIFICATION_CLIENT_SECRET'],
      'grant_type' => 'client_credentials',
      'redirect_uri' => 'http://konghq.com/'
    )

    req_options = {
      use_ssl: uri.scheme == 'https'
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end
    resp = JSON.parse response.body.gsub('=>', ':')
    resp['access_token']
  end
end
