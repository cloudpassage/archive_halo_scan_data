#!/usr/bin/env ruby

require 'halo-api-lib/client'
require 'halo-api-lib/server_issues'


module Halo

class Interface
  attr_reader :name, :ip_address

  def initialize(obj)
    @name = obj['name']
    @ip_address = obj['ip_address']
  end

  def to_s
    "#{name}=#{ip_address}"
  end
end

class Servers
  attr_reader :hostname, :id, :url, :interfaces, :connecting_addr, :state, :issues, :firewall_policy, :platform

  def initialize(obj)
    @issues = nil
    @hostname = obj['hostname']
    @id = obj['id']
    @url = obj['url']
    @connecting_addr = obj['connecting_ip_address']
    @state = obj['state']
    @platform = obj['platform']
    @interfaces = []
    obj['interfaces'].each { |interface| @interfaces << Interface.new(interface) }
  end

  def self.all(client,type = nil)
    resp_obj = self.all_first(client,type)
    my_list = resp_obj[:list]
    while (resp_obj[:next] != nil)
      resp_obj = self.all_next(client, resp_obj[:next])
      resp_obj[:list].each { |srvr| my_list << srvr }
    end
    my_list
  end

  def self.all_first(client,type,page_size = nil)
    url = "/v1/servers"
    if (type != nil) && (page_size != nil)
      url = "/v1/servers?per_page=#{page_size}&state=#{type}"
    elsif (type != nil)
      url = "/v1/servers?state=#{type}"
    elsif (page_size != nil)
      url = "/v1/servers?per_page=#{page_size}"
    else
      url = "/v1/servers"
    end
    self.all_next(client,url)
  end

  def self.all_next(client,url)
    response = client.get url    
    server_list = response.parsed['servers']
    pagination = response.parsed['pagination']
    next_url = nil
    if (pagination != nil)
      next_url = pagination['next']
    end
    my_list = []
    server_list.each { |server| my_list << Servers.new(server) }
    { :list => my_list, :next => next_url }
  end

  def details(client)
    response = client.get "/v1/servers/#{@id}"
    server_list = response.parsed['server']
    @hostname = obj['hostname']
    @id = obj['id']
    @url = obj['url']
    @connecting_addr = obj['connecting_ip_address']
    @state = obj['state']
    @interfaces = []
    obj['interfaces'].each { |interface| @interfaces << Interface.new(interface) }
    @firewall_policy = obj['firewall_policy'] # leaving as unparsed map
    self
  end

  def issues(client)
    response = client.get "/v1/servers/#{@id}/issues"
    # puts response.body
    issueData = response.parsed
    @issues = ServerIssues.new issueData
  end

  def detailed_issues(client)
    response = client.get "/v1/servers/#{@id}/sca"
    scaIssueData = response.parsed
    response = client.get "/v1/servers/#{@id}/svm"
    svmIssueData = response.parsed
    issueData = { 'sca' => scaIssueData['scan'], 'svm' => svmIssueData['scan'] }
    @issues = ServerIssues.new issueData
  end

  def remove_from_group(client)
    move_to_group(client,"Unassigned")
  end

  def move_to_group(client,group)
    data = { :server => { :group_id => group.id } }
    response = client.put("/v1/servers/#{id}",data)
    response.status # expects 204 for success
  end

  def start_scan(client,scan_type)
    data = { :scan => { :module => scan_type } }
    url = "/v1/servers/#{id}/scans"
    # puts "Scan: url=#{url} scan=#{scan_type}\n  data=#{data.to_s}"
    response = client.post(url,data)
    cmd = Halo::ServerCommands.new response.parsed['command']
  end

  def to_s
    s = "hostname=#{hostname} id=#{id} conn=#{connecting_addr} state=#{state}\n"
    @interfaces.each { |interface| s += "  Interface: #{interface}\n" }
    s += "  URL=#{url}"
  end
end

end # end of module
