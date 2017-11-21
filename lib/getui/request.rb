require 'uri'
require 'net/http'
require 'securerandom'

module Getui
  class Request < Net::HTTPRequest
    REQUEST_HAS_BODY = true
    RESPONSE_HAS_BODY = true
    MAX_TRY = 3

    def self.post(url, params = {})
      MAX_TRY.times do |current_try|
        begin
          uri = URI(url)
          req = Getui::PostRequest.new(uri)
          req.body = JSON.dump(params)
          http  = Net::HTTP.new(uri.hostname, uri.port)
          http.use_ssl = (uri.scheme == "https")
          return http.request(req)
        rescue Errno::ETIMEDOUT, Net::ReadTimeout, Timeout::Error, EOFError => e
          if current_try == MAX_TRY - 1
            raise e
          end
        end
      end
    end

    def self.get(url, params = {})
      MAX_TRY.times do |current_try|
        begin
          uri = URI(url)
          req = Getui::GetRequest.new(uri)
          http  = Net::HTTP.new(uri.hostname, uri.port)
          http.use_ssl = (uri.scheme == "https")
          return http.request(req)
        rescue Errno::ETIMEDOUT, Net::ReadTimeout, Timeout::Error, EOFError => e
          if current_try == MAX_TRY - 1
            raise e
          end
        end
      end
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
