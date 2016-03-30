$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "pry"
require "rails/all"
require "mysql2"
require "database_cleaner"

ENV['RAILS_ENV'] = "test"
require "support/test_app/config/environment"

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random
end
