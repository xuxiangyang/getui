require 'rest-client'
require 'digest'
require 'json'

module Getui
  module Auth
    class << self
      def auth_token
        Getui.cache_backend.fetch("Getui:#{Getui.app_id}:auth_token", expires_in: 12.hours) do
          Getui::Auth.generate
        end
      end

      def generate
        timestamp = ((Time.now.to_f) * 1000).to_i
        resp = RestClient.post(
                               "https://restapi.getui.com/v1/#{Getui.app_id}/auth_sign",
                               JSON.dump({
                                          timestamp: timestamp.to_s,
                                          sign: Digest::SHA256.new.hexdigest("#{Getui.app_key}#{timestamp}#{Getui.master_secret}"),
                                          appkey: Getui.app_key,
                                         }),
                               {
                                "Content-Type" => "application/json"
                               },
                              )
        res = JSON.parse(resp)
        raise Getui::GenerateAuthTokenError.new(resp.body) unless res["result"] == "ok"
        res["auth_token"]
      end
    end
  end
end
