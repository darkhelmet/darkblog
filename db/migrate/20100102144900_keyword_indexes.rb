class KeywordIndexes < ActiveRecord::Migration
  def self.up
    add_index :keywordings, :post_id
    add_index :keywordings, [:keyword_id, :post_id]
  end

  def self.down
  end
end
