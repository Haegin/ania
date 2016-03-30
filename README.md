# Ania - A Rails/SQL migration checker

Rails migrations are great, but in a busy production environment sometimes you
need to run raw SQL so you don't have to take the app down to migrate large
tables. This means you then need to maintain two sets of migrations; one Rails
version to use in development or any integration testing environments and an
SQL version to use in production. As soon as you have two versions then you
have the problem of keeping them in sync and ensuring they're changing your
database in the same way each time. This gem helps with this.

## Installation

Add this line to your Rails application's Gemfile:

```ruby
gem 'migration_checker'
```

And then execute:

    $ bundle

## Usage

The easiest way to use this gem is with the rake task the gem provides:

    rake db:check_migration

By default, this will check the most recent migration. You can also specify the
migration version to check with the `VERSION` environment variable:

    rake db:check_migration VERSION=20160319134129

For this gem to work your migrations need to have a particular format. The SQL
migration should be included in the same file after the `__END__` keyword. The
up migration should come first, followed by the down migration with them both
titled in uppercase (UP and DOWN respectively). For example:

```ruby
class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.belongs_to :author, null: false
      t.string :title, null: false
      t.string :slug, limit: 32
      t.text :content, null: false

      t.timestamps null: false
    end

    add_foreign_key :posts, :authors, name: :author_id_fk
  end
end


__END__

-- ======
-- = UP =
-- ======
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

-- ========
-- = DOWN =
-- ========

DROP TABLE `posts`;
DELETE FROM `schema_migrations` WHERE `schema_migrations`.`version` = '20160309103833';
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rspec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at
https://github.com/fac/ania.
