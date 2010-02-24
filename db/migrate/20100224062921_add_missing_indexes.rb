class AddMissingIndexes < ActiveRecord::Migration
  def self.up
    add_index :caches, :key
    add_index :keywords, :name
    add_index :tags, :name
    add_index :redirections, :old_permalink
  end

  def self.down
  end
end
