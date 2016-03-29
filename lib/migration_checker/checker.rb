require "migration_checker/migration_mismatch"

module MigrationChecker
  class Checker

    UP = /UP/.freeze
    DOWN = /DOWN/.freeze
    COMMENTS = /\A--/.freeze
    BLANK = /\A\s*\z/.freeze
    CLASS_DEFINITION = /class\s+(.*)\s+<\s+ActiveRecord::Migration/

    attr_reader :version

    def initialize(version)
      @version = version.to_i
    end

    def check!
      migrate_to_latest
      rails_migrated_schema = dump_db
      run_rails_down_migration
      rails_rolled_back_schema = dump_db
      run_sql_up_migration
      sql_migrated_schema = dump_db
      run_sql_down_migration
      sql_rolled_back_schema = dump_db
      check_schemas_match(rails_migrated_schema, sql_migrated_schema, "up") &&
        check_schemas_match(rails_rolled_back_schema, sql_rolled_back_schema, "down")
    ensure
      migrate_to_latest
    end

    def check_schemas_match(rails, sql, direction)
      if rails.first != sql.first
        File.open("rails-schema.rb", "w") { |f| f.write(rails.first) }
        File.open("sql-schema.rb", "w") { |f| f.write(sql.first) }
        raise MigrationMismatch, "The Rails schemas don't match after running the #{direction} migration. See rails-schema.rb and sql-schema.rb."
      elsif rails.second != sql.second
        File.open("rails-structure.sql", "w") { |f| f.write(rails.second) }
        File.open("sql-structure.sql", "w") { |f| f.write(sql.second) }
        raise MigrationMismatch, "The SQL structure dumps don't match after running the #{direction} migration. See rails-structure.sql and sql-structure.sql."
      end
      true
    end

    def up_sql
      filter(migration_lines.drop_while { |l| !UP.match(l) }.take_while { |l| !DOWN.match(l) }).join("\n")
    end

    def down_sql
      filter(migration_lines.drop_while { |l| !DOWN.match(l) }).join("\n")
    end

    def run_sql_up_migration
      puts "Running SQL up migration"
      up_sql.split(";").select(&:present?).each do |statement|
        ActiveRecord::Base.connection.execute(statement + ";")
      end
    end

    def run_sql_down_migration
      puts "Running SQL down migration"
      down_sql.split(";").select(&:present?).each do |statement|
        ActiveRecord::Base.connection.execute(statement + ";")
      end
    end

    def migrate_to_latest
      puts "Migrating to the latest version"
      ActiveRecord::Migrator.migrate(ActiveRecord::Tasks::DatabaseTasks.migrations_paths)
    end

    def run_rails_up_migration
      puts "Running Rails up migration"
      ActiveRecord::Migrator.run(:up, ActiveRecord::Tasks::DatabaseTasks.migrations_paths, version.to_i)
    end

    def run_rails_down_migration
      puts "Running Rails down migration"
      ActiveRecord::Migrator.run(:down, ActiveRecord::Tasks::DatabaseTasks.migrations_paths, version.to_i)
    end

    def dump_db
      [dump_rails_schema, dump_sql_structure]
    end

    def dump_rails_schema
      file = Tempfile.new("migration-checker")
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      file.rewind
      file.read
    ensure
      if file.respond_to?(:close)
        file.close
        file.unlink
      end
    end

    def dump_sql_structure
      file = Tempfile.new("migration-checker")
      mysql = ActiveRecord::Tasks::MySQLDatabaseTasks.new(Rails.configuration.database_configuration[Rails.env])
      mysql.structure_dump(file.path)
      file.rewind
      file.readlines[0..-2].join
    ensure
      if file.respond_to?(:close)
        file.close
        file.unlink
      end
    end

    private

    def filter(lines)
      lines.reject { |line| line =~ COMMENTS || line =~ BLANK }
    end

    def migration_lines
      @migration_lines ||= File.open(migration_filename).readlines.map(&:chomp)
    end

    def migration_filename
      Dir.glob(File.join(ActiveRecord::Tasks::DatabaseTasks.migrations_paths.first, "#{version}*.rb")).first
    end
  end
end
