RSpec.configure do |config|
  config.run_all_when_everything_filtered = true

  config.mock_with :rspec do |mocks|
    mocks.syntax = [:expect, :should]
  end

  config.expect_with(:rspec) { |c| c.syntax = :should }

  require File.dirname(__FILE__) + '/../lib/tracker-git'
  require 'tracker_api'
end
