require 'spec_helper'
require 'ostruct'

describe Tracker::Deliverer do

  let(:tracker_token) { double }
  let(:commited_story) { double(id: 1, current_state: current_state) }
  let(:uncommited_story) { double(id: 2, current_state: 'finished') }
  let(:finished_stories) { [commited_story, uncommited_story] }
  let(:project) { double }
  let(:git) { double }
  let(:deliverer) { Tracker::Deliverer.new(project, git) }
  let(:current_state) { 'finished' }

  let(:success_response) { OpenStruct.new(errors: OpenStruct.new(errors: [])) }

  describe '#mark_as_delivered' do
    context 'when called without argument' do
      it('should mark stories as delivered') do
        project.should_receive(:finished) { finished_stories }
        git.should_receive(:contains?).with(1, {}) { true }
        git.should_receive(:contains?).with(2, {}) { false }
        project.should_receive(:deliver).with(commited_story)
        project.should_not_receive(:deliver).with(uncommited_story)
        commited_story.should_not_receive(:create_comment)
        uncommited_story.should_not_receive(:create_comment)

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

    context 'with a comment to add' do
      it('should add the comment') do
        project.should_receive(:finished_and_delivered) { finished_stories }
        git.should_receive(:contains?).with(1, {}) { true }
        git.should_receive(:contains?).with(2, {}) { false }
        project.should_receive(:deliver).with(commited_story)
        commited_story.should_receive(:create_comment).with(text: "We like potatoes too")
        uncommited_story.should_not_receive(:create_comment)

        deliverer.mark_as_delivered(comment: 'We like potatoes too')
      end

      context 'story is already delivered' do
        let(:current_state) { 'delivered' }

        it 'should add the comment but not re-deliver the story' do
          project.should_receive(:finished_and_delivered) { finished_stories }
          git.should_receive(:contains?).with(1, {}) { true }
          git.should_receive(:contains?).with(2, {}) { false }
          project.should_not_receive(:deliver)
          commited_story.should_receive(:create_comment).with(text: "We like potatoes too")
          uncommited_story.should_not_receive(:create_comment)

          deliverer.mark_as_delivered(comment: 'We like potatoes too')
        end
      end
    end

    context 'errors are encountered' do
      it('should continue processing and raise an error at the end') do
        project.should_receive(:finished_and_delivered) { finished_stories }
        git.should_receive(:contains?).with(1, {}) { true }
        git.should_receive(:contains?).with(2, {}) { true }
        project.should_receive(:deliver).with(commited_story).and_raise RuntimeError
        project.should_receive(:deliver).with(uncommited_story)
        commited_story.should_receive(:create_comment).with(text: "We like potatoes too").and_raise RuntimeError
        uncommited_story.should_receive(:create_comment).with(text: "We like potatoes too")

        begin
          deliverer.mark_as_delivered(comment: 'We like potatoes too')
        rescue => e
          error = e
        end

        error.should_not be_nil
        error.message.split("\n").should eq [
          'Failed to delivery story 1: RuntimeError',
          'Failed to create note for story 1: We like potatoes too (RuntimeError)'
        ]
      end
    end
  end
end
