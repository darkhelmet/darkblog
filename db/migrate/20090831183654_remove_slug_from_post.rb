class RemoveSlugFromPost < ActiveRecord::Migration
  def self.up
    remove_column :posts, :slug
  end

  def self.down
  end
end
