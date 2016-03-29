require "rails"

module MigrationChecker
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/check_migration.rake"
    end
  end
end
