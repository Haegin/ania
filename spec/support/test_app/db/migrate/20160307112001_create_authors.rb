class CreateAuthors < ActiveRecord::Migration
  def change
    create_table :authors do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.text :bio

      t.timestamps null: false
    end
  end
end


__END__

-- ======
-- = UP =
-- ======
CREATE TABLE `authors` (
  `id` int(11) auto_increment PRIMARY KEY,
  `name` varchar(255) NOT NULL,
  `email` varchar(255) NOT NULL,
  `bio` text,
  `created_at` datetime NOT NULL,
  `updated_at` datetime NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

INSERT INTO `schema_migrations` (`version`) VALUES ('20160309103833');

-- ========
-- = DOWN =
-- ========

DROP TABLE `authors`;
DELETE FROM `schema_migrations` WHERE `schema_migrations`.`version` = '20160309103833';
