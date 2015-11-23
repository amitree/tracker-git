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
      collection = if comment then project.finished_and_delivered else project.finished end
      collection.each do |story|
        if git.contains?(story.id, options)
          puts " - Delivering story ##{story.id}"
          unless options[:dryrun]
            project.deliver(story) unless story.current_state == 'delivered'
            if comment
              story.notes.create(text: comment)
            end
          end
        end
      end
    end
  end
end
