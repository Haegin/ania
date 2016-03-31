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
  `title` varchar(255) NOT NULL,
  `slug` varchar(32),
  `content` text NOT NULL,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

ALTER TABLE `posts` ADD CONSTRAINT `author_id_fk` FOREIGN KEY (`author_id`) REFERENCES `authors` (`id`);

INSERT INTO `schema_migrations` (`version`) VALUES ('20160309103833');

-- ========
-- = DOWN =
-- ========

DROP TABLE `posts`;
DELETE FROM `schema_migrations` WHERE `schema_migrations`.`version` = '20160309103833';
