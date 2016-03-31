module Ania
  class Matcher

    attr_reader :expected, :actual

    def initialize(expected, actual)
      @expected = expected
      @actual = actual
    end

    def match?
      expected == actual
    end

    def write_output(suffix = "output", extension = "txt")
      File.open("rails-#{suffix}.#{extension}", "w") { |f| f.write(expected) }
      File.open("sql-#{suffix}.#{extension}", "w") { |f| f.write(actual) }
    end
  end
end
