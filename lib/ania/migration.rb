module Ania
  class Migration
    attr_reader :version

    UP = /UP/.freeze
    DOWN = /DOWN/.freeze
    COMMENTS = /\A--/.freeze
    BLANK = /\A\s*\z/.freeze

    def initialize(version)
      @version = version
    end

    def up_with_rails
      ActiveRecord::Migrator.run(:up, ActiveRecord::Tasks::DatabaseTasks.migrations_paths, version.to_i)
    end

    def down_with_rails
      ActiveRecord::Migrator.run(:down, ActiveRecord::Tasks::DatabaseTasks.migrations_paths, version.to_i)
    end

    def up_with_sql
      up_sql.split(";").select(&:present?).each do |statement|
        ActiveRecord::Base.connection.execute(statement + ";")
      end
    end

    def down_with_sql
      down_sql.split(";").select(&:present?).each do |statement|
        ActiveRecord::Base.connection.execute(statement + ";")
      end
    end

    private

    def up_sql
      filter(migration_lines.drop_while { |l| !UP.match(l) }.take_while { |l| !DOWN.match(l) }).join("\n")
    end

    def down_sql
      filter(migration_lines.drop_while { |l| !DOWN.match(l) }).join("\n")
    end

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
