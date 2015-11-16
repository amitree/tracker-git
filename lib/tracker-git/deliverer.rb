module Tracker
  class Deliverer
    attr_reader :project, :git
    def initialize(project, git)
      @project = project
      @git = git
    end

    def mark_as_delivered(options={})
      options = options.dup
      comment = options.delete(:comment)
      project.finished.each do |story|
        if git.contains?(story.id, options)
          puts " - Delivering story ##{story.id}"
          unless options[:dryrun]
            project.deliver(story)
            if comment
              story.notes.create(text: comment)
            end
          end
        end
      end
    end
  end
end
