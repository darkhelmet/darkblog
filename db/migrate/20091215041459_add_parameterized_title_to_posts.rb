class AddParameterizedTitleToPosts < ActiveRecord::Migration
  def self.up
    add_column :posts, :parameterized_title, :string
    Post.reset_column_information
    Post.all.map(&:save)
  end

  def self.down
    remove_column :posts, :parameterized_title
  end
end
