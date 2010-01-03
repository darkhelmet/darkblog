# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100102144900) do

  create_table "caches", :force => true do |t|
    t.string   "key"
    t.text     "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "keywordings", :force => true do |t|
    t.integer "keyword_id"
    t.integer "post_id"
  end

  add_index "keywordings", ["keyword_id", "post_id"], :name => "index_keywordings_on_keyword_id_and_post_id"
  add_index "keywordings", ["keyword_id"], :name => "index_keywordings_on_keyword_id"
  add_index "keywordings", ["post_id"], :name => "index_keywordings_on_post_id"

  create_table "keywords", :force => true do |t|
    t.string "name"
  end

  create_table "posts", :force => true do |t|
    t.string   "title"
    t.string   "category"
    t.text     "body"
    t.boolean  "published",           :default => false
    t.datetime "published_on"
    t.string   "cached_tag_list"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "permalink"
    t.boolean  "announced",           :default => false
    t.string   "parameterized_title"
  end

  add_index "posts", ["category"], :name => "index_posts_on_category"
  add_index "posts", ["permalink"], :name => "index_posts_on_permalink"

  create_table "redirections", :force => true do |t|
    t.integer  "post_id"
    t.string   "old_permalink"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type"], :name => "index_taggings_on_taggable_id_and_taggable_type"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

end
