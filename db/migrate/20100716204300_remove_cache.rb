class RemoveCache < ActiveRecord::Migration
  def self.up
    drop_table :caches
  end

  def self.down
    create_table :caches do |t|
      t.string :key, :unique => true
      t.text :value

      t.timestamps
    end
  end
end