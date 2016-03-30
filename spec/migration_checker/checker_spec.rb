require "spec_helper"

describe Ania::Checker do

  let(:version) { "20160309103833" }

  before { checker.migrate_to_latest }

  subject(:checker) { described_class.new(version) }

  it "can read the SQL for the up migration" do
    expected_sql = <<-END.chomp
CREATE TABLE `posts` (
  `id` int(11) auto_increment PRIMARY KEY,
  `author_id` int(11) NOT NULL,
  `title` varchar(255) NOT NULL COLLATE utf8_unicode_ci,
  `slug` varchar(32) COLLATE utf8_unicode_ci,
  `content` text NOT NULL COLLATE utf8_unicode_ci,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci;
ALTER TABLE `posts` ADD CONSTRAINT `author_id_fk` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`);
INSERT INTO `schema_migrations` (`version`) VALUES ('20160309103833');
    END
    expect(checker.up_sql).to eq expected_sql
  end

  it "can read the SQL for the up migration" do
    expected_sql = <<-END.chomp
DROP TABLE `posts`;
DELETE FROM `schema_migrations` WHERE `schema_migrations`.`version` = '20160309103833';
    END
    expect(checker.down_sql).to eq expected_sql
  end

  it "can run and roll back the migration using the Rails code" do
    checker.run_rails_down_migration
    expect { Post.count }.to raise_error(ActiveRecord::StatementInvalid)
    checker.run_rails_up_migration
    expect(Post.first).to eq nil
  end

  it "can run and roll back the migration using SQL" do
    checker.run_sql_down_migration
    expect { Post.count }.to raise_error(ActiveRecord::StatementInvalid)
    checker.run_sql_up_migration
    expect(Post.first).to eq nil
  end

  it "can dump the schema" do
    expect(checker.dump_rails_schema).to eq File.read(Rails.root.join("db", "schema.rb"))
  end

  it "can check the rails and SQL migrations match" do
    expect(checker.check!).to be_truthy
  end
end

