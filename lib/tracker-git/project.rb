require 'pivotal-tracker'

module Tracker
  class Project

    attr_reader :tracker_token

    def initialize(tracker_token)
      @tracker_token = tracker_token

      PivotalTracker::Client.token = tracker_token
      PivotalTracker::Client.use_ssl = true
    end

    def finished
      _projects.map{|project| project.stories.all(state: "finished", story_type: ['bug', 'feature'])}.flatten
    end

    def finished_and_delivered
      _projects.map{|project| project.stories.all(state: ["finished","delivered"], story_type: ['bug', 'feature'])}.flatten
    end

    def deliver(story)
      story.update(current_state: "delivered")
    end

    private
    def _projects
      @projects ||= PivotalTracker::Project.all
    end
  end
end
