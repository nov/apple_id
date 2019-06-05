require 'simplecov'

SimpleCov.start do
  add_filter 'spec'
end

require 'rspec'
require 'rspec/its'
require 'active_support'
require 'active_support/testing/time_helpers'
require 'apple_id'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"
  config.expect_with :rspec do |c|
    c.syntax = [:should, :expect]
  end
  config.include ActiveSupport::Testing::TimeHelpers
end

require 'support/webmock_helper'
