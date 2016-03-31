require "spec_helper"

describe Ania::Migration do

  let(:version) { "20160309103833" }

  subject(:migration) { described_class.new(version) }

  it "can run and roll back the migration using the Rails code" do
    migration.down_with_rails
    expect { Post.count }.to raise_error(ActiveRecord::StatementInvalid)
    migration.up_with_rails
    expect(Post.first).to eq nil
  end

  it "can run and roll back the migration using SQL" do
    migration.down_with_sql
    expect { Post.count }.to raise_error(ActiveRecord::StatementInvalid)
    migration.up_with_sql
    expect(Post.first).to eq nil
  end
end
