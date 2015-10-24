require 'spec_helper'

describe Tracker::Deliverer do

  let(:tracker_token) { double }
  let(:commited_story) { double(id: 1) }
  let(:uncommited_story) { double(id: 2) }
  let(:finished_stories) { [commited_story, uncommited_story] }
  let(:project) { double }
  let(:git) { double }
  let(:deliverer) { Tracker::Deliverer.new(project, git) }

  describe '#mark_as_delivered' do
    context 'when called without argument' do
      it('should mark stories as delivered') do
        project.should_receive(:finished) { finished_stories }
        git.should_receive(:contains?).with(1, {}) { true }
        git.should_receive(:contains?).with(2, {}) { false }
        project.should_receive(:deliver).with(commited_story)
        project.should_not_receive(:deliver).with(uncommited_story)

        deliverer.mark_as_delivered
      end
    end

    context 'when given a specific branch' do
      it('should mark stories as delivered') do
        project.should_receive(:finished) { finished_stories }
        git.should_receive(:contains?).with(1, {branch: 'develop'}) { true }
        git.should_receive(:contains?).with(2, {branch: 'develop'}) { false }
        project.should_receive(:deliver).with(commited_story)
        project.should_not_receive(:deliver).with(uncommited_story)

        deliverer.mark_as_delivered(branch: 'develop')
      end
    end

    context 'when given a specific range' do
      it('should mark stories as delivered') do
        project.should_receive(:finished) { finished_stories }
        git.should_receive(:contains?).with(1, {range: 'df65686e8c0c...5138d6290a80'}) { true }
        git.should_receive(:contains?).with(2, {range: 'df65686e8c0c...5138d6290a80'}) { false }
        project.should_receive(:deliver).with(commited_story)
        project.should_not_receive(:deliver).with(uncommited_story)

        deliverer.mark_as_delivered(range: 'df65686e8c0c...5138d6290a80')
      end
    end
  end

end
