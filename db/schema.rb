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

ActiveRecord::Schema.define(version: 20180209162606) do

  create_table "comments", force: :cascade do |t|
    t.string   "author_name"
    t.text     "body"
    t.integer  "task_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "comments", ["task_id"], name: "index_comments_on_task_id"

  create_table "projects", force: :cascade do |t|
    t.string   "title"
    t.string   "author"
    t.text     "description"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "projects", ["user_id"], name: "index_projects_on_user_id"

  create_table "tasks", force: :cascade do |t|
    t.string   "title"
    t.integer  "job_number"
    t.string   "author"
    t.text     "description"
    t.string   "status"
    t.integer  "parent_task"
    t.string   "assignee"
    t.integer  "task_id"
    t.integer  "project_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  add_index "tasks", ["project_id"], name: "index_tasks_on_project_id"
  add_index "tasks", ["task_id"], name: "index_tasks_on_task_id"

  create_table "users", force: :cascade do |t|
    t.string   "user_name"
    t.string   "email"
    t.string   "first_name"
    t.string   "last_name"
    t.boolean  "user_type"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "password_digest"
  end

end
