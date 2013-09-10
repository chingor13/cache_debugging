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

ActiveRecord::Schema.define(version: 20130910001826) do

  create_table "contracts", force: true do |t|
    t.integer  "worker_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "electricians", force: true do |t|
    t.boolean  "certified"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "gardeners", force: true do |t|
    t.boolean  "has_shovel"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "plumbers", force: true do |t|
    t.boolean  "has_wrench"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "tweets", force: true do |t|
    t.integer  "worker_id"
    t.string   "message"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "workers", force: true do |t|
    t.string   "name"
    t.string   "detail_type"
    t.integer  "detail_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
