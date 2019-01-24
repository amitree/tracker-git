module Tracker
  class Deliverer
    attr_reader :project, :git
    def initialize(project, git)
      @project = project
      @git = git
      @errors = []
    end

    def mark_as_delivered(options={})
      options = options.dup
      comment = options.delete(:comment)
      collection = if comment then project.finished_and_delivered else project.finished end
      collection.each do |story|
        if git.contains?(story.id, options)
          puts " - Delivering story ##{story.id}"
          unless options[:dryrun]
            unless story.current_state == 'delivered'
              begin
                result = project.deliver(story)
              rescue TrackerApi::Errors::ClientError,
                  TrackerApi::Errors::ServerError,
                  RuntimeError => e
                @errors << "Failed to delivery story #{story.id}: #{e.message}"
              end
            end
            if comment
              begin
                story.create_comment(text: comment)
              rescue TrackerApi::Errors::ClientError,
                  TrackerApi::Errors::ServerError,
                  RuntimeError => e
                @errors << "Failed to create note for story #{story.id}: #{comment} (#{e.message})"
              end
            end
          end
        end
      end

      raise @errors.join("\n") unless @errors.empty?
    end
  end
end
