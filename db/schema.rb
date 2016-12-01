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

ActiveRecord::Schema.define(version: 20161128144421) do

  create_table "attachments", force: :cascade do |t|
    t.string  "type"
    t.integer "workflow_id"
    t.text    "file_data"
    t.text    "metadata"
  end

  add_index "attachments", ["workflow_id"], name: "index_attachments_on_workflow_id"

  create_table "jobs", force: :cascade do |t|
    t.string  "type"
    t.integer "workflow_id"
    t.integer "status",      default: 0
    t.integer "result",      default: 0
    t.text    "metadata"
  end

  add_index "jobs", ["workflow_id"], name: "index_jobs_on_workflow_id"

  create_table "workflows", force: :cascade do |t|
    t.string  "type"
    t.string  "root"
    t.integer "status",   default: 0
    t.integer "result",   default: 0
    t.text    "metadata"
  end

end
