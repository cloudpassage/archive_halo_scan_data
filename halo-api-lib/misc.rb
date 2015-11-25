#!/usr/bin/env ruby

require 'halo-api-lib/client'

module Halo

  class ConfigurationPolicies
    attr_reader :id, :name, :description, :platform, :used_by

    def initialize(obj)
      @id = obj['id']
      @name = obj['name']
      @description = obj['description']
      @platform = obj['platform']
      @used_by = obj['used_by']
    end

    def self.all(client)
      response = client.get "/v1/policies"
      policy_list = response.parsed['policies']
      my_list = []
      policy_list.each { |policy| my_list << ConfigurationPolicies.new(policy) }
      my_list
    end

    def to_s
      s = "name=#{name} platform=#{platform}\n"
      s += "  id=#{id}\n"
      s += "  description=#{description}\n"
      if (@used_by != nil)
        s += "  used_by="
        @used_by.each { |ub| s += ub['name'] + " " }
      end
      s
    end
  end

  class FileIntegrityPatterns
    attr_accessor :pattern, :description, :inclusion

    def initialize(obj)
      @pattern = obj['pattern']
      @description = obj['description']
      @inclusion = obj['inclusion'] == "true"
    end

    def to_s
      s = (@inclusion == "true") ? "include" : "exclude"
      s += " pattern=#{pattern} description=#{description}"
      s
    end
  end

  class FileIntegrityRules
    attr_accessor :target, :description, :recurse, :critical, :alert, :pattern_list

    def initialize(obj)
      @target = obj['target']
      @description = obj['description']
      @recurse = obj['recurse'] == "true"
      @critical = obj['critical'] == "true"
      @alert = obj['alert'] == "true"
      @pattern_list = []
      plist = obj['patterns']
      if (plist != nil)
        plist.each { |pattern| @pattern_list << FileIntegrityPatterns.new(pattern) }
      end
    end

    def to_s
      s = "target=#{target} recurse=#{recurse} critical=#{critical} alert=#{alert}\n"
      s += "    description=#{description}"
      @pattern_list.each { |pattern| s += "\n      pattern: #{pattern.to_s}" }
      s
    end
  end

  class FileIntegrityPolicies
    attr_accessor :id, :name, :description, :platform, :rule_list

    def initialize(obj)
      @id = obj['id']
      @name = obj['name']
      @description = obj['description']
      @platform = obj['platform']
      @rule_list = []
      rlist = obj['rules']
      if (rlist != nil)
        rlist.each { |rule| @rule_list << FileIntegrityRules.new(rule) }
      end
    end

    def self.all(client)
      response = client.get "/v1/fim_policies"
      fim_list = response.parsed['fim_policies']
      my_list = []
      fim_list.each { |fim| my_list << FileIntegrityPolicies.new(fim) }
      my_list
    end

    def details(client)
      response = client.get "/v1/fim_policies/#{id}"
      obj = response.parsed['fim_policy']
      if (obj['description'] != nil)
        @description = obj['description']
      end
      rlist = obj['rules']
      if (rlist != nil)
        @rule_list = []
        if (rlist != nil)
          rlist.each { |rule| @rule_list << FileIntegrityRules.new(rule) }
        end
      end
      self
    end

    def delete(client)
      response = client.delete "/v1/fim_policies/#{@id}"
      response.status
    end

    def to_s
      s = "name=#{name} platform=#{platform}\n  id=#{id}\n  description=#{description}"
      @rule_list.each { |rule| s += "\n  rule: #{rule.to_s}" }
      s
    end
  end

end # end of module
