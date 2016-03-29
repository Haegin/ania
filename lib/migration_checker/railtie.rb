require "rails"

module MigrationChecker
  class Railtie < Rails::Railtie
    rake_tasks do
      require "tasks/check_migration.tasks"
    end
  end
end
