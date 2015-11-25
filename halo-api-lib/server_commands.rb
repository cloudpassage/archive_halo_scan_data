#!/usr/bin/env ruby

require 'halo-api-lib/client'

module Halo

class ServerCommands
  attr_reader :name, :id, :url, :status, :created_at, :updated_at, :result

  def initialize(obj)
    @name = obj['name']
    @id = obj['id']
    @url = obj['url']
    @status = obj['status']
    @created_at = obj['created_at']
    @updated_at = obj['updated_at']
    @result = obj['result']
  end

  def update_status(client)
    response = client.get(@url)
    obj = response.parsed['command']
    @name = obj['name']
    @id = obj['id']
    @url = obj['url']
    @status = obj['status']
    @created_at = obj['created_at']
    @updated_at = obj['updated_at']
    @result = obj['result']
    response.status
  end

end # class

class ScanStatus
  attr_reader :id, :url, :module, :status, :created_at, :completed_at, :requested_by
  attr_reader :server_id, :server_hostname, :server_url
  attr_reader :critical_findings_count, :noncritical_findings_count, :details

  def initialize(obj)
    @id = obj['id']
    @url = obj['url']
    @module = obj['module']
    @status = obj['status']
    @created_at = obj['created_at']
    @completed_at = obj['completed_at']
    @requested_by = obj['requested_by']
    @server_id = obj['server_id']
    @server_hostname = obj['server_hostname']
    @server_url = obj['server_url']
    @critical_findings_count = obj['critical_findings_count']
    @noncritical_findings_count = obj['non_critical_findings_count']
  end

  def self.all(client,page_size,page_num,since,ending,next_link)
    url = "/v1/scans"
    if (next_link == nil)
      params = nil
      params = "per_page=#{page_size}" if (page_size != nil)
      params = ((params == nil) ? "" : (params + "&")) + "page=#{page_num}" if (page_num != nil)
      params = ((params == nil) ? "" : (params + "&")) + "since=#{since}" if (since != nil)
      params = ((params == nil) ? "" : (params + "&")) + "until=#{ending}" if (ending != nil)
      url += "?" + params if (params != nil)
    else
      url += next_link.split(url)[1]
    end
    # puts "List Scans: url=#{url}"
    response = client.get(url)
    scan_list = []
    next_link = nil
    rcount = response.parsed['count']
    response_list = response.parsed['scans']
    response_list.each do |resp_obj|
      scan = ScanStatus.new resp_obj
      scan_list << scan
    end
    pagination = response.parsed['pagination']
    if (pagination != nil)
      next_link = pagination['next']
    end
    [scan_list, next_link, rcount]
  end

  def get_details(client,is_fim = false)
    url = "/v1/scans/#{@id}"
    response = client.get(url)
    scanObj = response.parsed['scan']
    @details = scanObj['findings']
    if (is_fim)
      [*@details].each do |result|
        if (result['url'] != nil)
          response = client.get(result['url'])
          result['details'] = response.parsed
        end
      end
    end
    @details = scanObj['server_accounts'] if (@details == nil)
  end

  def to_s
    s = "#{@module.upcase} scan on #{server_hostname}: #{status}"
    s += "\n  Server ID: #{server_id}"
    s += "\n  Started: #{created_at}"
    s += "  Completed: #{completed_at}" if (completed_at != nil)
    s += "  Requested by: #{requested_by}" if (requested_by != nil)
    if (critical_findings_count != nil) || (noncritical_findings_count != nil)
      s += "\n  Findings:"
      if (critical_findings_count != nil)
        s += " critical=#{critical_findings_count}"
      end
      if (noncritical_findings_count != nil)
        s += " noncritical=#{noncritical_findings_count}"
      end
    end
    s
  end
end #class

end # module
