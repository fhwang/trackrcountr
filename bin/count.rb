#!/usr/bin/env ruby

require 'csv'
require 'pivotal-tracker'
require "#{File.dirname(__FILE__)}/../config"

PivotalTracker::Client.token(USERNAME, PASSWORD)
project = PivotalTracker::Project.find(PROJECT_ID)
page_size = 5
offset = 0
counts_by_date_and_story_type = Hash.new { |outer_hash, date|
  outer_hash[date] = Hash.new(0)
}
stories = project.stories.all(
  state: 'accepted', limit: page_size, modified_since: Date.parse(START_DATE),
  includedone: true, offset: offset
)
while !stories.empty?
  stories.each do |story|
    date = story.accepted_at.to_date
    counts_by_date_and_story_type[date][story.story_type] += 1
  end
  offset += page_size
  stories = project.stories.all(
    state: 'accepted', limit: page_size, modified_since: Date.parse(START_DATE),
    includedone: true, offset: offset
  )
end
dates = counts_by_date_and_story_type.keys.sort
story_types = %w(bug chore feature release)
CSV do |csv_out|
  csv_out << [''] + story_types
  dates.each do |date|
    csv_row = [date.to_s]
    counts = counts_by_date_and_story_type[date]
    story_types.each do |story_type|
      csv_row << counts[story_type]
    end
    csv_out << csv_row
  end
end
