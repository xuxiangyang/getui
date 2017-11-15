module Getui
  class Message
    attr_accessor :is_offline, :offline_expire_time, :push_network_type, :message_type, :transmission_type, :transmission_content, :push_info
    def initialize(message_type, is_offline: true, offline_expire_time: 72 * 60 * 60 * 1000, push_network_type: 0)
      @transmission_type = 0
      @transmission_content = ""
      @message_type = message_type
      @is_offline = is_offline
      @offline_expire_time = offline_expire_time
      @push_network_type = push_network_type
    end

    def as_json
      {
       appkey: Getui.app_key,
       is_offline: self.is_offline,
       offline_expire_time: self.offline_expire_time,
       push_network_type: self.push_network_type,
       msgtype: message_type,
      }
    end
  end
end
