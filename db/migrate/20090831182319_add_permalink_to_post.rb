class AddPermalinkToPost < ActiveRecord::Migration
  def self.up
    add_column :posts, :permalink, :string
    add_index :posts, :permalink
    Post.reset_column_information
    Post.all.each do |post|
      post.update_attribute(:permalink, "/#{post.published_on_local.strftime('%Y/%m/%d')}/#{post.slug}")
    end
  end

  def self.down
    remove_column :posts, :permalink
  end
end
