module Getui
  class Message
    class Transmission < Getui::Message
      attr_accessor :transmission_type, :transmission_content, :apns
      def initialize(transmission_content, is_offline: true, offline_expire_time: 7 * 60 * 60 * 24, push_network_type: 0)
        super("transmission", is_offline: is_offline, offline_expire_time: offline_expire_time, push_network_type: push_network_type)
        @transmission_type = false
        @transmission_content = transmission_content
      end

      def as_json
        message_json = super
        json = {
                message: message_json,
                transmission: {
                               transmission_type: self.transmission_type,
                               transmission_content: self.transmission_content,
                              },
               }
        json[:push_info] = self.apns.as_json if self.apns
        json
      end
    end
  end
end
