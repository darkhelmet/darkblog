class CreateKeywordTables < ActiveRecord::Migration
  def self.up
    create_table :keywords do |t|
      t.string :name
    end

    create_table :keywordings do |t|
      t.integer :keyword_id
      t.integer :post_id
    end

    add_index :keywordings, :keyword_id
  end

  def self.down
    drop_table :keywords
    drop_table :keywordings
  end
end
