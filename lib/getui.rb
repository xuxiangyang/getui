require 'active_support/cache'
require 'json'
require 'securerandom'
require 'digest'
require 'net/http'
require "getui/version"
require "getui/errors"
require "getui/message"
require "getui/message/transmission"
require "getui/apple"

module Getui
  REQUEST_MAX_RETRY = 3

  attr_accessor :app_id, :app_key, :master_secret

  def initialize(app_id:, app_key:, master_secret:)
    @app_id = app_id
    @app_key = app_key
    @master_secret = master_secret
  end

  def push_single(cid, message)
    json = message.as_json(app_key)
    json[:cid] = cid
    json[:requestid] = SecureRandom.uuid[0..29]
    resp = post("https://restapi.getui.com/v1/#{app_id}/push_single", json)
    res = JSON.parse(resp.body)
    if res['result'] == 'ok'
      res
    else
      raise Getui::PushError resp.body
    end
  end

  def save_list_body(message)
    json = message.as_json(app_key)
    resp = post("https://restapi.getui.com/v1/#{app_id}/save_list_body", json)
    res = JSON.parse(resp.body)
    if res['result'] == 'ok'
      res["taskid"]
    else
      raise Getui::PushError resp.body
    end
  end

  def push_list(cids, taskid, need_detail: true)
    json = { cid: cids, taskid: taskid, need_detail: need_detail }
    resp = post("https://restapi.getui.com/v1/#{app_id}/push_list", json)
    res = JSON.parse(resp.body)
    if res['result'] == 'ok'
      res
    else
      raise Getui::PushError resp.body
    end
  end

  def push_app(message)
    json = message.as_json(app_key)
    resp = post("https://restapi.getui.com/v1/#{app_id}/push_app", json)
    res = JSON.parse(resp.body)
    if res['result'] == 'ok'
      res
    else
      raise Getui::PushError resp.body
    end
  end

  def user_status(cid)
    resp = get("https://restapi.getui.com/v1/#{app_id}/user_status/#{cid}")
    JSON.parse(resp.body)
  end

  private

  def auth_token
    Getui.cache_backend.fetch("Getui:#{app_id}:auth_token", expires_in: 12.hours, race_condition_ttl: 1.minutes) do
      timestamp = (Time.now.to_f * 1000).to_i
      body = {
        timestamp: timestamp.to_s,
        sign: Digest::SHA256.new.hexdigest("#{app_key}#{timestamp}#{master_secret}"),
        appkey: app_key,
      }
      uri = URI("https://restapi.getui.com/v1/#{app_id}/auth_sign")
      req = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json' })
      req.body = JSON.dump(body)
      http = Net::HTTP.new(uri.hostname, uri.port)
      http.use_ssl = (uri.scheme == "https")
      resp = http.request(req)
      res = JSON.parse(resp)
      if res["result"] == "ok"
        res["auth_token"]
      else
        raise Getui::GenerateAuthTokenError, resp.body
      end
    end
  end

  def post(url, params = {})
    REQUEST_MAX_RETRY.times do |current_try|
      begin
        uri = URI(url)
        req = Net::HTTP::Post.new(uri.path, { 'Content-Type' => 'application/json', 'authtoken' => auth_token })
        req.body = JSON.dump(params)
        http = Net::HTTP.new(uri.hostname, uri.port)
        http.use_ssl = (uri.scheme == "https")
        return http.request(req)
      rescue Errno::ETIMEDOUT, Net::ReadTimeout, EOFError => e
        if current_try == REQUEST_MAX_RETRY - 1
          raise e
        end
      end
    end
  end

  def get(url)
    REQUEST_MAX_RETRY.times do |current_try|
      begin
        uri = URI(url)
        req = Net::HTTP::Get.new(uri.path, { 'Content-Type' => 'application/json', 'authtoken' => auth_token })
        http = Net::HTTP.new(uri.hostname, uri.port)
        http.use_ssl = (uri.scheme == "https")
        return http.request(req)
      rescue Errno::ETIMEDOUT, Timeout::Error, EOFError => e
        if current_try == REQUEST_MAX_RETRY - 1
          raise e
        end
      end
    end
  end

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
