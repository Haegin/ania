module Ania
  class Schema
    def dump
      Tempfile.open("ania") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
        file.rewind
        file.read
      end
    end
  end
end
