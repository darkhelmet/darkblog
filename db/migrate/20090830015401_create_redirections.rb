class CreateRedirections < ActiveRecord::Migration
  def self.up
    create_table :redirections do |t|
      t.integer :post_id
      t.string :old_permalink

      t.timestamps
    end
  end

  def self.down
    drop_table :redirections
  end
end
