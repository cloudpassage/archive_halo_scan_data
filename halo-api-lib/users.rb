#!/usr/bin/env ruby

require 'halo-api-lib/client'

module Halo

class Users
  attr_reader :username, :id, :url, :email, :firstname, :lastname, :active
  attr_reader :portal_access, :ghostport_access, :last_login_at, :last_login_ip, :created_at

  def initialize(obj)
    @username = obj['username']
    @id = obj['id']
    @url = obj['url']
    @email = obj['email']
    @firstname = obj['firstname']
    @lastname = obj['lastname']
    @active = obj['active'] == 'true'
    @portal_access = obj['portal_access'] == 'true'
    @ghostport_access = obj['ghostport_access'] == 'true'
    @last_login_at = nil
    @last_login_ip = nil
    @created_at = nil
  end

  def self.all(client)
    response = client.get "/v1/users"
    user_list = response.parsed['users']
    my_list = []
    user_list.each { |user| my_list << Users.new(user) }
    my_list
  end

  def details(client)
    response = client.get "/v1/users/#{id}"
    obj = response.parsed['user']
    @last_login_at = obj['last_login_at']
    @last_login_ip = obj['last_login_ip']
    @created_at = obj['created_at']
    self
  end

  def to_s
    s = "username=#{username} id=#{id} active=#{active} email=#{email}\n"
    s += "  realname=#{firstname} #{lastname}\n"
    s += "  portal_access=#{portal_access} ghostport_access=#{ghostport_access}\n  "
    if (created_at != nil)
      s += "created_at=#{created_at}\n  "
    end
    if (last_login_at != nil) && (last_login_ip != nil)
      s += "last login: at #{last_login_at} from #{last_login_ip}"
    end
    s
  end
end

class ServerAccounts
  attr_reader :username, :uid, :gid, :comment, :home, :last_login_at, :last_login_from, :url
  attr_reader :home_exists, :groups, :last_password_change, :days_warn_before_password_expiration
  attr_reader :minimum_days_between_password_changes, :maximum_days_between_password_changes
  attr_reader :disabled_after_days_inactive, :days_since_disabled
  attr_reader :ssh_authorized_keys, :sudo_access
  attr_accessor :server_id

  def initialize(obj)
    @url = obj['url']
    @username = obj['username']
    @uid = obj['uid']
    @gid = obj['gid']
    @comment = obj['comment']
    @home = obj['home']
    @last_login_at = obj['last_login_at']
    @last_login_from = obj['last_login_from']
    @server_id = nil
    @home_exists = nil
    @groups = nil
    @last_password_change = nil
    @days_warn_before_password_expiration = nil
    @minimum_days_between_password_changes = nil
    @maximum_days_between_password_changes = nil
    @disabled_after_days_inactive = nil
    @days_since_disabled = nil
    @ssh_authorized_keys = nil
    @sudo_access = nil
  end

  def self.all(client,server_id)
    response = client.get "/v1/servers/#{server_id}/accounts"
    account_list = response.parsed['accounts']
    my_list = []
    account_list.each do |account|
      act = ServerAccounts.new(account)
      act.server_id = server_id
      my_list << act
    end
    my_list
  end

  def details(client)
    response = client.get "/v1/servers/#{server_id}/accounts/#{username}"
    obj = response.parsed['account']
    @home_exists = obj['home_exists']
    @groups = obj['groups']
    @last_password_change = obj['last_password_change']
    @days_warn_before_password_expiration = obj['days_warn_before_password_expiration']
    @minimum_days_between_password_changes = obj['minimum_days_between_password_changes']
    @maximum_days_between_password_changes = obj['maximum_days_between_password_changes']
    @disabled_after_days_inactive = obj['disabled_after_days_inactive']
    @days_since_disabled = obj['days_since_disabled']
    @ssh_authorized_keys = obj['ssh_authorized_keys']
    @sudo_access = obj['sudo_access']
    self
  end

  def to_s
    s = "username=#{username} uid=#{uid} gid=#{gid}\n  url=#{url}\n"
    s += "  home=#{home} comment=#{comment}"
    if (last_login_at != nil) && (last_login_from != nil)
      s += "\n  last login: at #{last_login_at} from #{last_login_from}"
    end
    if (ssh_authorized_keys != nil)
      ssh_authorized_keys.each { |key| s += "    #{key.to_s}\n" }
    end
    s
  end
end

end # end of module
