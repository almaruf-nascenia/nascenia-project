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

ActiveRecord::Schema.define(version: 20150731085219) do

  create_table "developers", force: true do |t|
    t.string   "name"
    t.string   "designation"
    t.date     "joining_date"
    t.float    "previous_job_exp", limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "work_load",                   default: 0
    t.boolean  "active",                      default: true
  end

  create_table "project_teams", force: true do |t|
    t.integer  "project_id"
    t.integer  "developer_id"
    t.float    "participation_percentage",          limit: 24
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status",                                       default: 1
    t.date     "status_date"
    t.boolean  "most_recent_data",                             default: true
    t.integer  "previous_participation_percentage",            default: 0
  end

  create_table "project_time_sheets", force: true do |t|
    t.string   "Title"
    t.string   "Description"
    t.string   "Link"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "project_id"
  end

  create_table "projects", force: true do |t|
    t.string   "name"
    t.string   "title"
    t.text     "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "priority"
    t.boolean  "active",      default: true
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",    null: false
    t.string   "encrypted_password",     default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider"
    t.string   "uid"
    t.string   "name"
    t.boolean  "admin",                  default: false
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
