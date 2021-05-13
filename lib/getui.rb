require 'active_support/cache'
require "getui/version"
require "getui/errors"
require "getui/message"
require "getui/message/transmission"
require "getui/apple"
require 'getui/client'

module Getui
  class << self
    def cache_backend
      if defined? Rails
        @cache_backend ||= Rails.cache
      else
        @cache_backend ||= ActiveSupport::Cache::MemoryStore.new
      end
    end
  end
end
