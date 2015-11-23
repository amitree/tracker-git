require 'spec_helper'

describe Tracker::Git do
  describe "#search" do
    let(:message) { "[#123456] some message" }
    let(:story_id) { 123456 }
    let(:branch) { "master" }
    let(:range) { nil }
    let(:query) { "git log #{branch} #{range}".strip }

    before do
      git.should_receive(:`).with(query) { message }
    end
    let(:git) { Tracker::Git.new }

    context "defaults" do
      it "searches via system calls using default branch" do
        git.contains?(story_id).should == true
      end
    end

    context "passing branch" do
      let(:branch) { "test" }
      it "searches via system calls using given branch" do
        git.contains?(story_id, branch: branch).should == true
      end
    end

    context "passing range" do
      let(:range) { "df65686e8c0c...5138d6290a80" }
      it "searches via system calls using given range" do
        git.contains?(story_id, branch: branch, range: range).should == true
      end
    end

    context "no result found" do
      let(:message) { "no story id here" }
      it "returns false" do
        git.contains?(story_id).should == false
      end
    end

    context "not quite matching the story id" do
      let(:message) { "[#1234567] another message" }
      it "returns false" do
        git.contains?(story_id).should == false
      end
    end

    context "multiple stories" do
      let(:message) { "[#123456] [#1234567] some message" }
      it "matches first story" do
        git.contains?(123456).should == true
      end
      it "matches second story" do
        git.contains?(1234567).should == true
      end
    end

    context "story number not in brackets" do
      let(:message) { "#123456 some message" }
      it "returns true" do
        git.contains?(story_id).should == true
      end
    end
  end
end
