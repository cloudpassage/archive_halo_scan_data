#!/usr/bin/env ruby

require 'halo-api-lib/client'

module Halo

class SpecialEventsPolicies
  attr_reader :name, :id, :description, :global, :used_by

  def initialize(obj)
    @name = obj['name']
    @id = obj['id']
    @description = obj['description']
    @global = obj['global']
    if (obj['used_by'] != nil)
      @used_by = []
      ublist = obj['used_by']
      ublist.each { |ub| @used_by << ub }
    else
      @used_by = nil
    end
  end

  def self.all(client)
    response = client.get "/v1/special_events_policies"
    inlist = response.parsed['special_events_policies']
    outlist = []
    inlist.each { |policy| outlist << SpecialEventsPolicies.new(policy) }
    outlist
  end

  def to_s
    s = "name=#{name} global=#{global} id=#{id}\n  description=#{description}"
    if (@used_by != nil)
      @used_by.each { |ub| s += "\n  used by: \"#{ub['name']}\" id=#{ub['id']}" }
    end
    s
  end
end # class SpecialEventsPolicies

end # module
