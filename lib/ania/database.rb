module Ania
  class Database
    def migrate_to_latest
      ActiveRecord::Migrator.migrate(ActiveRecord::Tasks::DatabaseTasks.migrations_paths)
    end

    def dump
      Tempfile.open("migration-checker") do |file|
        mysql = ActiveRecord::Tasks::MySQLDatabaseTasks.new(Rails.configuration.database_configuration[Rails.env])
        mysql.structure_dump(file.path)
        file.rewind
        file.readlines[0..-2].join
      end
    end
  end
end
