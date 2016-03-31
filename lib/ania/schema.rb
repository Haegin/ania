module Ania
  class Schema
    def dump
      file = Tempfile.new("ania")
      ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      file.rewind
      file.read
    ensure
      if file.respond_to?(:close)
        file.close
        file.unlink
      end
    end
  end
end
