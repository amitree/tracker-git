require 'spec_helper'

describe Tracker::Project do

  let(:tracker_token) { double }
  let(:the_project) { double }
  let(:feature) { double }
  let(:bug) { double }

  describe "#initialize" do
    it "initializes the project class" do
      project = Tracker::Project.new(tracker_token)
      project.should be
      project.tracker_token.should == tracker_token
    end
  end

  context 'queries' do
    let(:query) { double }

    before do
      PivotalTracker::Project.should_receive(:all) { [the_project] }
      the_project.should_receive(:stories) { query }
    end

    describe "#finished" do
      before do
        query.should_receive(:all).with(state: "finished", story_type: ['bug', 'feature']) { [feature, bug] }
      end

      it "retrieves finished stories and bugs" do
        project = Tracker::Project.new(tracker_token)
        project.finished.should == [feature, bug]
      end
    end

    describe "#finished_and_delivered" do
      let(:query) { double }

      before do
        query.should_receive(:all).with(state: ["finished","delivered"], story_type: ['bug', 'feature']) { [feature, bug] }
      end

      it "retrieves finished and delivered stories and bugs" do
        project = Tracker::Project.new(tracker_token)
        project.finished_and_delivered.should == [feature, bug]
      end
    end
  end

  describe "#deliver" do
    let(:project) { Tracker::Project.new(double) }
    let(:story) { double }

    it "marks the story as delivered" do
      story.should_receive(:update).with(current_state: "delivered")
      project.deliver(story)
    end
  end

end
