#!/usr/bin/env ruby

require 'halo-api-lib/client'

module Halo

class ServerGroups
  attr_reader :name, :id, :url, :firewall_policy_id, :linux_firewall_policy_id, :windows_firewall_policy_id

  def initialize(obj)
    @name = obj['name']
    @id = obj['id']
    @url = obj['url']
    @firewall_policy_id = obj['firewall_policy_id']
    @linux_firewall_policy_id = obj['linux_firewall_policy_id']
    @windows_firewall_policy_id = obj['windows_firewall_policy_id']
  end

  def self.all(client)
    response = client.get "/v1/groups"
    group_list = response.parsed['groups']
    my_list = []
    group_list.each { |group| my_list << ServerGroups.new(group) }
    my_list
  end

  def servers(client)
    resp_obj = self.servers_first(client)
    my_list = resp_obj[:list]
    while (resp_obj[:next] != nil)
      resp_obj = self.servers_next(client, resp_obj[:next])
      resp_obj[:list].each { |srvr| my_list << srvr }
    end
    my_list
  end

  def servers_first(client,page_size = 1000)
    self.servers_next(client,"/v1/groups/#{id}/servers?per_page=#{page_size}")
  end

  def servers_next(client,url)
    response = client.get(url)
    server_list = response.parsed['servers']
    my_list = []
    server_list.each { |server| my_list << Servers.new(server) }
    pagination = response.parsed['pagination']
    next_url = nil
    if (pagination != nil)
      next_url = pagination['next']
    end
    { :list => my_list, :next => next_url }
  end

  def create(client)
    gdata = { :name => @name, :tag => nil }
    gdata['policy_ids'] = []
    gdata['windows_firewall_policy_id'] = @windows_firewall_policy_id
    gdata['linux_firewall_policy_id'] = @linux_firewall_policy_id
    data = { :group => gdata }
    response = client.post("/v1/groups",data)
    if response.status == 201
      obj = response.parsed
      gr_obj = obj['group']
      if gr_obj != nil
        @id = gr_obj['id']
        @url = gr_obj['url']
      end
    end
    response.status
  end

  def delete(client)
    response = client.delete "/v1/groups/#{@id}?moved_to_unassigned=true"
    response.status
  end

  def setFirewallPolicy(client,platform,id)
    gdata = {}
    if platform == 'windows'
      gdata['windows_firewall_policy_id'] = id
    elsif platform == 'linux'
      gdata['linux_firewall_policy_id'] = id
    else
      return -1
    end
    data = { :group => gdata }
    response = client.put("/v1/groups/#{@id}",data)
    response.status
  end

  def to_s
    s = "name=#{name}  id=#{id}\n"
    s += "  fw_policy=#{firewall_policy_id}\n"
    s += "  linux_fw_policy=#{linux_firewall_policy_id}\n"
    s += "  windows_fw_policy=#{windows_firewall_policy_id}\n"
    s += "  URL=#{url}"
  end
end

end # end of module
