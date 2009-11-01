class RenameTwitteredAgain < ActiveRecord::Migration
  def self.up
    rename_column :posts, :twittered, :announced
  end
  
  def self.down
    rename_column :posts, :announced, :twittered
  end
end