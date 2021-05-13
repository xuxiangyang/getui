module Getui
  class Apns
    attr_accessor :auto_badge, :body, :sound, :payload, :title

    def initialize(body, title: "", payload: nil)
      @body = body
      @title = title
      @auto_badge = "1"
      @payload = payload
      @sound = "default"
    end

    def as_json
      {
        aps: {
          alert: {
            body: self.body,
            title: self.title,
          },
          autoBadge: self.auto_badge,
          sound: self.sound,
        },
        payload: payload,
      }
    end
  end
end
