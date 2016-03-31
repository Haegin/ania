require "spec_helper"

describe Ania::Database do

  subject(:database) { described_class.new }

  describe "#migrate_to_latest" do
    before { Ania::Migration.new(20160309103833).down_with_rails }

    it "migrates to the latest version of the DB" do
      expect { database.migrate_to_latest }.to change {
        ActiveRecord::Migrator.current_version
      }.from(20160307112001).to(20160309103833)
    end
  end

  describe "#dump" do
    it "dumps out the structure of the database in SQL" do
      expect(database.dump).to eq File.read(File.join("spec", "support", "db_dump.sql"))
    end
  end
end
