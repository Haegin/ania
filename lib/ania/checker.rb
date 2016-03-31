require "ania/migration_mismatch"

module Ania
  class Checker

    attr_reader :migration

    def initialize(version)
      @migration = Migration.new(version.to_i)
    end

    def check!
      database.migrate_to_latest
      rails_migrated_schema = dump_db
      migration.down_with_rails
      rails_rolled_back_schema = dump_db
      migration.up_with_sql
      sql_migrated_schema = dump_db
      migration.down_with_sql
      sql_rolled_back_schema = dump_db
      check_schemas_match(rails_migrated_schema, sql_migrated_schema, "up") &&
        check_schemas_match(rails_rolled_back_schema, sql_rolled_back_schema, "down")
    ensure
      database.migrate_to_latest
    end

    private

    def check_schemas_match(rails, sql, direction)
      if !(matcher = Matcher.new(rails.first, sql.first)).match?
        matcher.write_output("schema", "rb")
        raise MigrationMismatch, "The Rails schemas don't match after running the #{direction} migration. See rails-schema.rb and sql-schema.rb."
      elsif !(matcher = Matcher.new(rails.second, sql.second)).match?
        matcher.write_output("structure", "sql")
        raise MigrationMismatch, "The SQL structure dumps don't match after running the #{direction} migration. See rails-structure.sql and sql-structure.sql."
      end
      true
    end

    def dump_db
      [schema.dump, database.dump]
    end

    def database
      @database ||= Database.new
    end

    def schema
      @schema ||= Schema.new
    end
  end
end
