#!/usr/bin/env ruby

require 'halo-api-lib/client'


module Halo

class Events
  attr_reader :actor_username, :actor_country, :actor_ip_address, :actor_key_id, :actor_key_label
  attr_reader :actor_username, :api_key_id, :api_key_label, :created_at, :critical, :daemon_version
  attr_reader :message, :name, :object_name, :policy_name, :previous_daemon_version, :rule_name
  attr_reader :server_account_id, :server_account_username, :server_group_name, :server_hostname, :server_id
  attr_reader :server_interface_name, :server_ip_address, :server_new_ip_address, :server_old_ip_address
  attr_reader :server_platform, :status, :target_username

  def initialize(obj)
    @actor_username = obj['actor_username']
    @actor_country = obj['actor_country']
    @actor_ip_address = obj['actor_ip_address']
    @actor_key_id = obj['actor_key_id']
    @actor_key_label = obj['actor_key_label']
    @actor_username = obj['actor_username']
    @api_key_id = obj['api_key_id']
    @api_key_label = obj['api_key_label']
    @created_at = obj['created_at']
    @critical = obj['critical']
    @daemon_version = obj['daemon_version']
    @message = obj['message']
    @name = obj['name']
    @object_name = obj['object_name']
    @policy_name = obj['policy_name']
    @previous_daemon_version = obj['previous_daemon_version']
    @rule_name = obj['rule_name']
    @server_account_id = obj['server_account_id']
    @server_account_username = obj['server_account_username']
    @server_group_name = obj['server_group_name']
    @server_hostname = obj['server_hostname']
    @server_id = obj['server_id']
    @server_interface_name = obj['server_interface_name']
    @server_ip_address = obj['server_ip_address']
    @server_new_ip_address = obj['server_new_ip_address']
    @server_old_ip_address = obj['server_old_ip_address']
    @server_platform = obj['server_platform']
    @status = obj['status']
    @target_username = obj['target_username']
  end

  def self.all_first(client,page_size,start_datetime = nil)
    url = "/v1/events?per_page=#{page_size}"
    if (page_size != nil)
      url += "&since=#{start_datetime}"
    end
    self.all_next(client,url)
  end

  def self.all_next(client,url)
    response = client.get url
    event_list = response.parsed['events']
    my_list = []
    event_list.each { |event| my_list << Events.new(event) }
    resp_obj = {}
    resp_obj['evlist'] = my_list
    pagination = response.parsed['pagination']
    if (pagination != nil)
      resp_obj['next'] = pagination['next']
    end
    resp_obj
  end

  def to_s
    s = "name=\"#{name}\" time=#{created_at}\n  msg=#{message}"
  end
end

end # end of module
