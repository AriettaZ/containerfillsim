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

ActiveRecord::Schema.define(version: 20141114170640) do

  create_table "containers", force: true do |t|
    t.string   "name"
    t.string   "measurement_scale"
    t.string   "fluid_type"
    t.float    "kinematic_viscosity"
    t.float    "density"
    t.float    "outlet_pressure"
    t.float    "inlet_vx"
    t.float    "inlet_vy"
    t.float    "inlet_vz"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "inlet_file_name"
    t.string   "inlet_content_type"
    t.integer  "inlet_file_size"
    t.datetime "inlet_updated_at"
    t.string   "outlet_file_name"
    t.string   "outlet_content_type"
    t.integer  "outlet_file_size"
    t.datetime "outlet_updated_at"
    t.string   "walls_file_name"
    t.string   "walls_content_type"
    t.integer  "walls_file_size"
    t.datetime "walls_updated_at"
    t.integer  "steps",               default: 5
  end

  create_table "jobs", force: true do |t|
    t.string   "status"
    t.string   "pbsid"
    t.string   "job_path"
    t.integer  "container_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "jobs", ["container_id"], name: "index_jobs_on_container_id"

end
