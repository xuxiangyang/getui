require 'uri'
require 'net/http'
require 'securerandom'

module Getui
  class Request < Net::HTTPRequest
    REQUEST_HAS_BODY = true
    RESPONSE_HAS_BODY = true

    def self.post(url, params = {})
      uri = URI(url)
      req = Getui::PostRequest.new(uri)
      req.body = JSON.dump(params)
      http  = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = (uri.scheme == "https")
      http.request(req)
    end

    def self.get(url, params = {})
      uri = URI(url)
      req = Getui::GetRequest.new(uri)
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


module Getui
  class PostRequest < Getui::Request
    METHOD = 'POST'
  end
end


module Getui
  class GetRequest < Getui::Request
    METHOD = 'GET'
  end
end
