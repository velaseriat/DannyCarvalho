# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20150818002020) do

  create_table "albums", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "paypal",         limit: 255
    t.text     "description",    limit: 65535
    t.string   "price",          limit: 255
    t.string   "image_filepath", limit: 255
    t.string   "bandcamp_id",    limit: 255
    t.datetime "release"
  end

  create_table "alohas", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.text     "content",    limit: 65535
  end

  create_table "blogs", force: :cascade do |t|
    t.string   "blogId",     limit: 255
    t.datetime "published"
    t.string   "blogUrl",    limit: 255
    t.string   "title",      limit: 255
    t.text     "content",    limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "event_images", force: :cascade do |t|
    t.string   "event_id",       limit: 255
    t.string   "image_filepath", limit: 255
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
  end

  create_table "events", force: :cascade do |t|
    t.string   "summary",        limit: 255
    t.text     "description",    limit: 65535
    t.string   "image_filepath", limit: 255
    t.string   "location",       limit: 255
    t.datetime "dateTime"
    t.string   "event_id",       limit: 255
    t.datetime "endDateTime"
  end

  create_table "igrams", force: :cascade do |t|
    t.string   "image_path", limit: 255
    t.string   "link",       limit: 255
    t.text     "text",       limit: 65535
    t.datetime "dateTime"
    t.string   "url",        limit: 255
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  create_table "photos", force: :cascade do |t|
    t.string   "image_filepath", limit: 255
    t.datetime "dateTime"
    t.text     "text",           limit: 65535
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "title",          limit: 255
  end

  create_table "products", force: :cascade do |t|
    t.string   "name",           limit: 255
    t.string   "image_filepath", limit: 255
    t.string   "price",          limit: 255
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.string   "paypal",         limit: 255
    t.integer  "album_id",       limit: 4
    t.text     "data",           limit: 65535
    t.datetime "release"
  end

  create_table "songs", force: :cascade do |t|
    t.string   "title",       limit: 255
    t.string   "duration",    limit: 255
    t.string   "filepath",    limit: 255
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
    t.text     "description", limit: 65535
  end

  create_table "subscribers", force: :cascade do |t|
    t.string   "email",      limit: 255
    t.boolean  "opted_out",  limit: 1
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "first_name",             limit: 255
    t.string   "last_name",              limit: 255
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.string   "email",                  limit: 255, default: "", null: false
    t.string   "encrypted_password",     limit: 255, default: "", null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "uploader",               limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "videos", force: :cascade do |t|
    t.string   "title",         limit: 255
    t.string   "url_path",      limit: 255
    t.datetime "created_at",                  null: false
    t.datetime "updated_at",                  null: false
    t.string   "thumbnail_url", limit: 255
    t.text     "description",   limit: 65535
  end

end
