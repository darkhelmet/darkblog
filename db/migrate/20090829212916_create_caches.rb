class CreateCaches < ActiveRecord::Migration
  def self.up
    create_table :caches do |t|
      t.string :key, :unique => true
      t.text :value

      t.timestamps
    end
  end

  def self.down
    drop_table :caches
  end
end
