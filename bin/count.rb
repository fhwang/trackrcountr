#!/usr/bin/env ruby

require 'csv'
require 'pivotal-tracker'
require "#{File.dirname(__FILE__)}/../config"
require "#{File.dirname(__FILE__)}/../lib/trackrcountr/report"

report = Trackrcountr::Report.new(
  USERNAME, PASSWORD, PROJECT_ID, Date.parse(START_DATE)
)
report.collect
puts report.to_csv
