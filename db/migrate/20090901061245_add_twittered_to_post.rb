class AddTwitteredToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :twittered, :boolean, :default => false
  end

  def self.down
    remove_column :posts, :twittered
  end
end
