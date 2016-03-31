require "spec_helper"

describe Ania::Schema do

  subject(:schema) { described_class.new }

  it "can dump the schema" do
    expect(schema.dump).to eq File.read(Rails.root.join("db", "schema.rb"))
  end
end
