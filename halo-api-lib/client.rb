#!/usr/bin/env ruby

require 'rubygems' # only _needed_ in Ruby 1.8 (but harmless in 1.9)
require 'oauth2'
require 'json'

module Halo

class ClientStats
  attr_accessor :call_count, :total_time

  def initialize
    @call_count = 0
    @total_time = 0
    @start_time = nil
  end

  def start
    @start_time = Time.now
  end

  def stop
    if (@start_time != nil)
      @call_count += 1
      stop_time = Time.now
      @total_time += stop_time - @start_time
    end
  end
end

class Client
  attr_accessor :key_id, :key_secret, :base_url, :proxy_opt, :stats

  def initialize
    @oauth_client = nil
    @base_url = nil
    @key_id = nil
    @key_secret = nil
    @proxy_opt = nil
    if ENV['https_proxy'].to_s.length > 0
      @proxy_opt = ENV['https_proxy']
    end
    @stats = {}
  end

  def getStatsBucket
    thread_id = Thread.current.object_id
    bucket = @stats[thread_id]
    if (bucket == nil)
      bucket = ClientStats.new
      @stats[thread_id] = bucket
    end
    bucket
  end

  def configure(key_id,key_secret,base_url)
    @base_url = base_url
    @key_id = key_id
    @key_secret = key_secret
  end

  def connect
    if @proxy_opt == nil
      @oauth_client = OAuth2::Client.new(@key_id,@key_secret,
                                         :site => @base_url,
                                         :token_url => '/oauth/access_token')
    else
      @oauth_client = OAuth2::Client.new(@key_id,@key_secret,
                                         :connection_opts => { :proxy => @proxy_opt },
                                         :site => @base_url,
                                         :token_url => '/oauth/access_token')
    end
  end

  def token
    begin
      if @oauth_client == nil
        connect
      end
      @oauth_client.client_credentials.get_token.token
    rescue Faraday::Error::ConnectionFailed => conn_err
      ex = ConnectionException.new(conn_err.to_s)
      raise ex
    rescue Errno::ETIMEDOUT => timeout_err
      ex = ConnectionException.new(timeout_err.to_s)
      raise ex
    rescue OAuth2::Error => oauth_err
      ex = convertOauthErrorToApi(oauth_err,"LOGIN","/oath/access_token")
      raise ex
    end
  end

  def convertOauthErrorToApi(oauth_err, method, url)
    if (oauth_err.response.status == 401) || (oauth_err.response.status == 403)
      ex = AuthException.new(oauth_err.response.status,oauth_err.code)
    else
      ex = FailedException.new(oauth_err.response.status,oauth_err.code)
    end
    ex.error_body = oauth_err.response.body
    ex.url = url
    ex.method = method
    if (oauth_err.response.body != nil) && (oauth_err.response.parsed != nil)
      obj = oauth_err.response.parsed
      if (obj.has_key? "error_description")
        ex.error_description = obj["error_description"]
      elsif (obj.has_key? "message")
        ex.error_msg = obj["message"]
        if (obj.has_key? "errors")
          err_list = obj["errors"]
          err_list.each { |err| ex.error_description = err["details"] }
        end
      end
    end
    ex
  end

  def get(url)
    begin
      getStatsBucket().start
      auth_header = "Bearer #{self.token}"
      resp = @oauth_client.request(:get, url, :headers => { :authorization => auth_header } )
      getStatsBucket().stop
      resp
    rescue Faraday::Error::ConnectionFailed => conn_err
      ex = ConnectionException.new(conn_err.to_s)
      raise ex
    rescue Errno::ETIMEDOUT => timeout_err
      ex = ConnectionException.new(timeout_err.to_s)
      raise ex
    rescue OAuth2::Error => oauth_err
      ex = convertOauthErrorToApi(oauth_err,"GET",url)
      raise ex
    end
  end

  def put(url,raw_data)
    begin
      getStatsBucket().start
      auth_header = "Bearer #{self.token}"
      data = JSON.generate raw_data
      # puts "Data: #{data}\nURL: #{url}"
      my_headers = { :authorization => auth_header, 'content-type' => "application/json" }
      resp = @oauth_client.request(:put, url, :headers => my_headers, :body => data )
      getStatsBucket().stop
      resp
    rescue Faraday::Error::ConnectionFailed => conn_err
      ex = ConnectionException.new(conn_err.to_s)
      raise ex
    rescue Errno::ETIMEDOUT => timeout_err
      ex = ConnectionException.new(timeout_err.to_s)
      raise ex
    rescue OAuth2::Error => oauth_err
      ex = convertOauthErrorToApi(oauth_err,"PUT",url)
      raise ex
    end
  end

  def post(url,raw_data)
    begin
      getStatsBucket().start
      auth_header = "Bearer #{self.token}"
      data = JSON.generate raw_data
      # puts "Data: #{data}\nURL: #{url}"
      my_headers = { :authorization => auth_header, 'content-type' => "application/json" }
      resp = @oauth_client.request(:post, url, :headers => my_headers, :body => data )
      getStatsBucket().stop
      resp
    rescue Faraday::Error::ConnectionFailed => conn_err
      ex = ConnectionException.new(conn_err.to_s)
      raise ex
    rescue Errno::ETIMEDOUT => timeout_err
      ex = ConnectionException.new(timeout_err.to_s)
      raise ex
    rescue OAuth2::Error => oauth_err
      ex = convertOauthErrorToApi(oauth_err,"POST",url)
      raise ex
    end
  end

  def delete(url)
    begin
      getStatsBucket().start
      auth_header = "Bearer #{self.token}"
      resp = @oauth_client.request(:delete, url, :headers => { :authorization => auth_header } )
      getStatsBucket().stop
      resp
    rescue Faraday::Error::ConnectionFailed => conn_err
      ex = ConnectionException.new(conn_err.to_s)
      raise ex
    rescue Errno::ETIMEDOUT => timeout_err
      ex = ConnectionException.new(timeout_err.to_s)
      raise ex
    rescue OAuth2::Error => oauth_err
      ex = convertOauthErrorToApi(oauth_err,"DELETE",url)
      raise ex
    end
  end
end

end # end of module
