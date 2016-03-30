$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require "pry"
require "rails/all"
require "mysql2"
require "database_cleaner"

# module Ania
#   class Application < ::Rails::Application
#     self.config.secret_key_base = "ASecretString" if config.respond_to?(:secret_key_base)
#   end
# end
# I18n.enforce_available_locales = true if I18n.respond_to?(:enforce_available_locales)

ENV['RAILS_ENV'] = "test"
require "support/test_app/config/environment"

# DatabaseCleaner.strategy = :truncation

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random

  # config.before(:all) do
  #   db_config = {
  #     adapter: "mysql2",
  #     host: "localhost",
  #     username: "root",
  #     database: "migration_checker_test"
  #   }
  #   ActiveRecord::Base.establish_connection(db_config)
  #   ActiveRecord::Tasks::DatabaseTasks.migrations_paths = [Rails.root.join("spec", "migrations").to_s]
  #   Rails.env = "test"
  #   Rails.configuration.database_configuration = {test: db_config}
  # end

#   config.before(:each) do
#     DatabaseCleaner.clean
#   end
end
