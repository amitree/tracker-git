require 'spec_helper'

describe Tracker::Project do

  let(:tracker_token) { double }
  let(:the_project) { double }
  let(:feature) { double }
  let(:bug) { double }
  let(:tracker_client) { double }

  describe '#initialize' do
    it 'initializes the project class' do
      project = Tracker::Project.new(tracker_token)
      project.should be
      project.tracker_token.should == tracker_token
    end
  end

  context 'queries' do
    let(:query) { double }

    before do
      TrackerApi::Client.should_receive(:new).with(token: tracker_token).and_return(tracker_client)
      tracker_client.should_receive(:projects).and_return([the_project])
    end

    describe '#finished' do
      before do
        the_project.should_receive(:stories).with(filter: 'state:finished type:bug,feature').and_return([feature, bug ])
      end

      it 'retrieves finished stories and bugs' do
        project = Tracker::Project.new(tracker_token)
        project.finished.should == [feature, bug]
      end
    end

    describe '#finished_and_delivered' do
      let(:query) { double }

      before do
        the_project.should_receive(:stories).with(filter: 'state:finished,delivered type:bug,feature').and_return([feature, bug ])
      end

      it 'retrieves finished and delivered stories and bugs' do
        project = Tracker::Project.new(tracker_token)
        project.finished_and_delivered.should == [feature, bug]
      end
    end
  end

  describe '#deliver' do
    let(:project) { Tracker::Project.new(double) }
    let(:story) { double }

    it 'marks the story as delivered' do
      story.should_receive(:current_state=).with('delivered')
      story.should_receive(:save)
      project.deliver(story)
    end
  end

end
