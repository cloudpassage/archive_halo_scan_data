#!/usr/bin/env ruby

require 'halo-api-lib/client'

module Halo

class Vulnerability
  attr_reader :cve_entry, :suppressed

  def initialize(obj)
    @cve_entry = obj['cve_entry']
    @suppressed = obj['suppressed']
  end

  def to_s
    "cve_entry=#{cve_entry} suppressed=#{suppressed}"
  end
end

class PackageInfo
  attr_reader :package_name, :package_version, :critical, :status, :cve_entries

  def initialize(obj)
    @package_name = obj['package_name']
    @package_version = obj['package_version']
    @critical = obj['critical']
    @status = obj['status']
    @cve_entries = []
    list = obj['cve_entries']
    list.each { |item| @cve_entries << Vulnerability.new(item) }
  end

  def to_s
    s = "package: name=#{package_name} version=#{package_version}\n"
    s += "      critical=#{critical} status=#{status}"
    cve_entries.each { |entry| s += "\n        #{entry}" }
    s
  end
end

class PackageList
  attr_reader :status, :critical_findings_count, :non_critical_findings_count
  attr_reader :findings, :created_at, :completed_at

  def initialize(obj)
    obj = obj['scan'] if (obj['scan'] != nil)

    @status = obj['status']

    @critical_findings = 0
    s = obj['critical_findings_count']
    @critical_findings = s.to_i unless s == nil

    @non_critical_findings = 0
    s = obj['non_critical_findings_count']
    @non_critical_findings = s.to_i unless s == nil

    @created_at = obj['created_at']
    @completed_at = obj['completed_at']

    @findings = []
    list = obj['findings']
    list.each { |item| @findings << PackageInfo.new(item) }
  end

  def to_s
    s = "  software issues: status=#{@status}\n"
    s += "    created=#{@created_at} completed=#{@completed_at}\n"
    s += "    count=[ critical=#{@critical_findings} non-critical=#{@non_critical_findings} ]"
    @findings.each { |finding| s += "\n    " + finding.to_s }
    s
  end
end

class FindingDetails
  attr_reader :type, :target, :actual, :expected, :status, :scan_status
  attr_reader :config_key, :config_key_value_delimiter

  def initialize(obj)
    @type = obj['type']
    @target = obj['target']
    @actual = obj['actual']
    @expected = obj['expected']
    @status = obj['status']
    @scan_status = obj['scan_status']
    @config_key = obj['config_key']
    @config_key_value_delimiter = obj['config_key_value_delimiter']
  end

  def to_s
    s = "type=#{@type} status=#{@status} scan_status=#{@scan_status}\n"
    s += "      config_key=#{@config_key} delimiter=#{@config_key_value_delimiter}\n"
    s += "      target=#{@target}\n"
    s += "      expected=#{@expected}\n"
    s += "      actual=#{@actual}\n"
  end
end

class Finding
  attr_reader :critical, :rule_name, :details, :status

  def initialize(obj)
    @critical = obj['critical']
    @rule_name = obj['rule_name']
    @status = obj['status']
    @details = []
    detailsList = obj['details']
    detailsList.each { |detail| @details << FindingDetails.new(detail) }
  end

  def to_s
    s = "rule_name=#{@rule_name} critical=#{@critical} status=#{@status}\n      "
    s += @details.to_s
  end
end

class ConfigIssues
  attr_reader :critical_findings, :non_critical_findings, :status, :findings
  attr_reader :created_at, :completed_at

  def initialize(obj)
    obj = obj['scan'] if (obj['scan'] != nil)
    @critical_findings = 0
    s = obj['critical_findings_count']
    @critical_findings = s.to_i unless s == nil

    @non_critical_findings = 0
    s = obj['non_critical_findings_count']
    @non_critical_findings = s.to_i unless s == nil

    @created_at = obj['created_at']
    @completed_at = obj['completed_at']

    @status = obj['status']
    @findings = []
    findings_list = obj['findings']
    findings_list.each { |finding| @findings << Finding.new(finding) }
  end

  def to_s
    s = "  config issues: status=#{@status}\n"
    s += "    created=#{@created_at} completed=#{@completed_at}\n"
    s += "    count=[ critical=#{@critical_findings} non-critical=#{@non_critical_findings} ]\n"
    @findings.each { |finding| s += "    " + finding.to_s }
    s
  end
end

class ServerIssues
  attr_reader :sca, :svm

  def initialize(obj)
    o = obj['sca']
    @sca = ConfigIssues.new(o) if (o != nil)
    o = obj['svm']
    @svm = PackageList.new(o) if (o != nil)
  end

  def to_s
    s = "\n"
    s += "#{sca}\n" if @sca != nil
    s += "#{svm}\n" if @svm != nil
    s
  end
end

end # end of module
