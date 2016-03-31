require "spec_helper"

describe Ania::Checker do

  let(:version) { "20160309103833" }

  before do
    Ania::Database.new.migrate_to_latest
  end

  subject(:checker) { described_class.new(version) }

  it "can check the rails and SQL migrations match" do
    expect(checker.check!).to be_truthy
  end
end

