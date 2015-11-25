#!/usr/bin/env ruby

require 'halo-api-lib/client'

module Halo

class FirewallInterfaces
  attr_reader :name, :id, :system, :url

  def initialize(obj)
    @name = obj['name']
    @id = obj['id']
    @system = obj['system']
    @url = obj['url']
  end

  def self.all(client)
    response = client.get "/v1/firewall_interfaces"
    inlist = response.parsed['firewall_interfaces']
    outlist = []
    inlist.each { |intrfc| outlist << FirewallInterfaces.new(intrfc) }
    outlist
  end

  def create(client)
    data = { 'firewall_interface' => { 'name' => @name } }
    response = client.post("/v1/firewall_interfaces",data)
    ok = (response.status >= 200) && (response.status < 300)
    if ok
      data = response.parsed['firewall_interface']
      if data != nil
        @id = data['id']
        @system = data['system']
        @url = data['url']
      end
    end
    ok
  end

  def delete(client)
    response = client.delete "/v1/firewall_interfaces/#{@id}"
    response.status
  end

  def to_s
    "name=#{name} system=#{system} id=#{id}\n  url=#{url}"
  end

  def to_obj
    obj = { }
    obj['name'] = @name
    obj['id'] = @id
    obj['system'] = @system
    obj['url'] = @url
    obj
  end

  def to_json
    JSON.pretty_generate(to_obj)
  end
end

class FirewallServices
  attr_reader :name, :id, :system, :url, :port, :protocol

  def initialize(obj)
    @name = obj['name']
    @id = obj['id']
    @system = obj['system']
    @url = obj['url']
    @port = obj['port']
    @protocol = obj['protocol']
  end

  def self.all(client)
    response = client.get "/v1/firewall_services"
    inlist = response.parsed['firewall_services']
    outlist = []
    inlist.each { |svc| outlist << FirewallServices.new(svc) }
    outlist
  end

  def create(client)
    svc_data = { 'name' => @name, 'protocol' => @protocol }
    svc_data['port'] = @port if @port != nil
    data = { 'firewall_service' =>  svc_data }
    response = client.post("/v1/firewall_services",data)
    ok = (response.status >= 200) && (response.status < 300)
    if ok
      data = response.parsed['firewall_service']
      if data != nil
        @id = data['id']
        @system = data['system']
        @url = data['url']
      end
    end
    ok
  end

  def delete(client)
    response = client.delete "/v1/firewall_services/#{@id}"
    response.status
  end

  def to_s
    "name=#{name} port=#{port}/#{protocol} system=#{system}\n  id=#{id}\n  url=#{url}"
  end

  def to_obj
    obj = { }
    obj['name'] = @name
    obj['id'] = @id
    obj['system'] = @system
    obj['url'] = @url
    obj['port'] = @port
    obj['protocol'] = @protocol
    obj
  end

  def to_json
    JSON.pretty_generate(to_obj)
  end
end

class FirewallZones
  attr_reader :name, :id, :system, :url, :ip_address, :used_by

  def initialize(obj)
    @name = obj['name']
    @id = obj['id']
    @system = obj['system']
    @url = obj['url']
    @ip_address = obj['ip_address']
    @used_by = obj['used_by'] # not going to parse, just an array of maps, with keys "id" and "name"
  end

  def self.all(client)
    response = client.get "/v1/firewall_zones"
    inlist = response.parsed['firewall_zones']
    outlist = []
    inlist.each { |zone| outlist << FirewallZones.new(zone) }
    outlist
  end

  def details(client)
    response = client.get("/v1/firewall_zones/#{id}")
    obj = response.parsed['firewall_zone']
    @name = obj['name']
    @id = obj['id']
    @system = obj['system']
    @url = obj['url']
    @ip_address = obj['ip_address']
    @used_by = obj['used_by'] # not going to parse, just an array of maps, with keys "id" and "name"
    self
  end

  def create(client)
    zone_data = { 'name' => @name, 'ip_address' => @ip_address }
    data = { 'firewall_zone' =>  zone_data }
    response = client.post("/v1/firewall_zones",data)
    ok = (response.status >= 200) && (response.status < 300)
    if ok
      data = response.parsed['firewall_zone']
      if data != nil
        @id = data['id']
        @system = data['system']
        @url = data['url']
        @used_by = data['used_by'] # probably nil, since it was just created
      end
    end
    ok
  end

  def clone(client,new_name,new_ip)
    obj = details(client).to_obj
    obj['name'] = new_name if (new_name != nil)
    obj['ip_address'] = new_ip if (new_ip != nil)
    my_clone = FirewallZones.new(obj)
    if my_clone.create(client)
      my_clone 
    else
      nil
    end
  end

  def delete(client)
    response = client.delete "/v1/firewall_zones/#{@id}"
    response.status
  end

  def to_s
    s = "name=#{name} system=#{system} ip=#{ip_address}\n"
    s += "  id=#{id}\n  url=#{url}"
    @used_by.each { |ub| s += "  used_by: name=#{ub['name']} id=#{ub['id']}\n" }
    s
  end

  def to_obj
    obj = {}
    obj['name'] = @name
    obj['id'] = @id
    obj['system'] = @system
    obj['url'] = @url
    obj['ip_address'] = @ip_address
    obj['used_by'] = @used_by
    obj
  end

  def to_json
    JSON.pretty_generate(to_obj)
  end
end

class FirewallRules
  attr_reader :id, :url, :connection_states, :action, :log, :chain, :parent, :source, :service, :interface

  def initialize(obj,parent)
    @parent = parent
    @id = obj['id']
    @url = obj['url']
    @connection_states = obj['connection_states']
    @action = obj['action']
    @active = obj['active']
    @log = obj['log']
    @chain = obj['chain']
    @interface = obj['firewall_interface']
    @source = obj['firewall_source']
    @service = obj['firewall_service']
  end

  def self.generate_rule(chain,policy,svc = nil)
    rule = { "log" => false, "active" => true }
    rule["chain"] = chain
    rule["action"] = policy
    rule["connection_states"] = nil
    rule["firewall_interface"] = nil
    rule["firewall_source"] = nil
    if svc == nil
      rule["firewall_service"] = nil
    else
      rule["firewall_service"] = svc.id
    end
    rule
  end

  def delete(client)
    url = "/v1/firewall_policies/#{@parent.id}/firewall_rules/#{@id}"
    response = client.delete url
    response.status
  end

  def to_obj
    rule = { "log" => @log, "active" => @active }
    rule["id"] = @id
    rule["chain"] = @chain
    rule["action"] = @action
    rule["connection_states"] = @connection_states
    rule["firewall_interface"] = @interface
    rule["firewall_source"] = @source
    rule["firewall_service"] = @service
    rule
  end

  def to_s
    s = "  chain=#{chain} action=#{action} log=#{log}\n"
    s += "    id=#{id}\n"
    s += "    source=#{source}\n"
    s += "    connection_states=#{connection_states}\n"
    s += "    URL=#{url}"
  end

  def to_json
    JSON.pretty_generate(to_obj)
  end
end

class FirewallPolicies
  attr_accessor :name, :description
  attr_reader :id, :url, :platform, :rule_list

  def initialize(obj)
    @name = obj['name']
    @id = obj['id']
    @url = obj['url']
    @platform = obj['platform']
    @description = obj['description']
    @rule_list = []
    rlist = obj['firewall_rules']
    if rlist != nil
      rlist.each { |rule| @rule_list << FirewallRules.new(rule,self) }
    end
  end

  def self.all(client)
    response = client.get "/v1/firewall_policies"
    policy_list = response.parsed['firewall_policies']
    my_list = []
    policy_list.each { |policy| my_list << FirewallPolicies.new(policy) }
    my_list
  end

  def rules(client)
    response = client.get "/v1/firewall_policies/#{id}/firewall_rules"
    rule_list = response.parsed['firewall_rules']
    my_list = []
    rule_list.each { |rule| my_list << FirewallRules.new(rule,self) }
    @rule_list = my_list
  end

  def create(client)
    response = client.post("/v1/firewall_policies",to_obj)
    ok = (response.status >= 200) && (response.status < 300)
    if ok
      data = response.parsed['firewall_policy']
      if data != nil
        @id = data['id']
        @system = data['system']
        @url = data['url']
      end
    end
    response.status
  end

  def update(client)
    obj = { 'group' => { 'name' => @name, 'description' => @description } }
    response = client.put("/v1/firewall_policies/#{id}",obj)
    ok = (response.status >= 200) && (response.status < 300)
    if ok
      data = response.parsed['firewall_policy']
      if data != nil
        @id = data['id']
        @system = data['system']
        @url = data['url']
      end
    end
    response.status
  end

  def add_rule(client,rule,position)
    rule['position'] = position
    wrapper_obj = { 'firewall_rule' => rule }
    response = client.post("/v1/firewall_policies/#{id}/firewall_rules",wrapper_obj)
    response.status
  end

  def self.generate_policy(name, platform, description, drop_svc_list = nil, accept_svc_list = nil)
    fwPolicy = { "name" => name, "platform" => platform }
    rule_list = []
    rule_list << FirewallRules.generate_rule("INPUT", "DROP")
    if platform == "windows"
      if drop_svc_list != nil
        drop_svc_list.each { |svc| rule_list << FirewallRules.generate_rule("OUTPUT","DROP",svc) }
      end
      if accept_svc_list != nil
        accept_svc_list.each { |svc| rule_list << FirewallRules.generate_rule("OUTPUT","ACCEPT",svc) }
      end
    else
      rule_list << FirewallRules.generate_rule("OUTPUT", "DROP")
    end
    fwPolicy["firewall_rules"] = rule_list
    fwPolicy["description"] = description
    if platform == "windows"
      fwPolicy["log_allowed"] = true;
      fwPolicy["log_dropped"] = true;
      fwPolicy["block_inbound"] = true;
      fwPolicy["block_outbound"] = false;
    end
    { "firewall_policy" => fwPolicy }
  end

  def to_obj
    fwPolicy = { "name" => @name, "platform" => @platform }
    rlist = [ ]
    @rule_list.each { |rule| rlist << rule.to_obj }
    fwPolicy["firewall_rules"] = rlist
    fwPolicy["description"] = @description
    if @platform == "windows"
      fwPolicy["log_allowed"] = true;
      fwPolicy["log_dropped"] = true;
      fwPolicy["block_inbound"] = true;
      fwPolicy["block_outbound"] = false;
    end
    { "firewall_policy" => fwPolicy }
  end

  def to_json
    JSON.pretty_generate(to_obj)
  end

  def delete(client)
    response = client.delete "/v1/firewall_policies/#{@id}"
    response.status
  end

  def to_s
    s = "name=#{name}\n  platform=#{platform} id=#{id}\n"
    s += "  URL=#{url}"
  end
end

end # end of module
