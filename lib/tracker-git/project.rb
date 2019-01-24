require 'tracker_api'

module Tracker
  class Project

    attr_reader :tracker_token

    def initialize(tracker_token)
      @tracker_token = tracker_token

      @client = TrackerApi::Client.new(token: tracker_token)
    end

    def finished
      _projects.map { |project| project.stories(filter: 'state:finished type:bug,feature') }.flatten
    end

    def finished_and_delivered
      _projects.map { |project| project.stories(filter: 'state:finished,delivered type:bug,feature') }.flatten
    end

    def deliver(story)
      story.current_state = 'delivered'
      story.save
    end

    private
    def _projects
      @projects ||= @client.projects
    end
  end
end
