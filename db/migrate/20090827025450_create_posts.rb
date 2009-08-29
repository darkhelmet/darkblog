class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :posts do |t|
      t.string :title
      t.string :slug
      t.string :category
      t.text :body
      t.boolean :published, :default => false
      t.datetime :published_on
      t.string :cached_tag_list
      
      t.timestamps
    end
    
    add_index :posts, :slug
    add_index :posts, :category
  end

  def self.down
    drop_table :posts
  end
end
