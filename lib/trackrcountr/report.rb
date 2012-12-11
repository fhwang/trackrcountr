module Trackrcountr
  class Report
    def initialize(username, password, project_id, start_date)
      PivotalTracker::Client.token(username, password)
      @project = PivotalTracker::Project.find(project_id)
      @start_date = start_date
      @counts_by_date_and_story_type = Hash.new { |outer_hash, date|
        outer_hash[date] = Hash.new(0)
      }
      @page_size = 100
      @offset = 0
    end

    def collect
      stories = get_stories
      while !stories.empty?
        stories.each do |story|
          date = story.accepted_at.to_date
          @counts_by_date_and_story_type[date][story.story_type] += 1
        end
        @offset += @page_size
        stories = get_stories
      end
    end

    def get_stories
      @project.stories.all(
        state: 'accepted', limit: @page_size, 
        modified_since: @start_date, includedone: true, offset: @offset
      )
    end

    def to_csv
      dates = @counts_by_date_and_story_type.keys.sort
      story_types = %w(bug chore feature release)
      CSV.generate do |csv_out|
        csv_out << [''] + story_types
        dates.each do |date|
          csv_row = [date.to_s]
          counts = @counts_by_date_and_story_type[date]
          story_types.each do |story_type|
            csv_row << counts[story_type]
          end
          csv_out << csv_row
        end
      end
    end
  end
end
