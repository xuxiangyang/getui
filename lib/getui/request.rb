require 'uri'
require 'net/http'
require 'securerandom'
module Getui
  class Request < Net::HTTPRequest
    METHOD = 'POST'
    REQUEST_HAS_BODY = true
    RESPONSE_HAS_BODY = true

    def self.request(url, params = {})
      uri = URI(url)
      req = Getui::Request.new(uri)
      req.body = JSON.dump(params)
      http  = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.request(req)
    end

    def initialize(path)
      super(path, {'Content-Type' => 'application/json', 'authtoken' => Getui::Auth.auth_token})
    end

    private

    def capitalize(name)
      name
    end
  end
end
