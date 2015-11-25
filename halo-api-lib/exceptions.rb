#!/usr/bin/env ruby

module Halo

class ConnectionException < RuntimeError
  attr_accessor :error_descr

  def initialize(err)
    @error_descr = err
  end
end

class ApiException < RuntimeError
  attr_accessor :http_status, :error_msg, :error_description, :error_body, :url, :method

  def initialize(hstat,msg)
    @http_status = hstat
    @error_msg = msg
    @error_description = nil
    @error_body = nil
  end
end

class AuthException < ApiException
  def initialize(hstat,msg)
    super(hstat,msg)
  end
end

class FailedException < ApiException
  def initialize(hstat,msg)
    super(hstat,msg)
  end
end

end # end of module
