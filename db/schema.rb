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

ActiveRecord::Schema.define(version: 20150907115748) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "abuse_notes_infos", force: :cascade do |t|
    t.integer  "abuse_report_id"
    t.string   "reported_by"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.string   "action"
  end

  create_table "abuse_report_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "abuse_reports", force: :cascade do |t|
    t.integer  "abuse_report_type_id"
    t.integer  "reported_by"
    t.integer  "processed_by"
    t.boolean  "processed",            default: false
    t.text     "comment"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
  end

  create_table "background_jobs", force: :cascade do |t|
    t.integer  "user_id"
    t.jsonb    "data"
    t.string   "status"
    t.string   "info"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "comments", force: :cascade do |t|
    t.integer  "commentable_id"
    t.string   "commentable_type"
    t.integer  "user_id"
    t.text     "content"
    t.datetime "created_at",       null: false
    t.datetime "updated_at",       null: false
  end

  add_index "comments", ["commentable_type", "commentable_id"], name: "index_comments_on_commentable_type_and_commentable_id", using: :btree

  create_table "ddos_infos", force: :cascade do |t|
    t.integer  "abuse_report_id"
    t.integer  "registered_domains"
    t.integer  "free_dns_domains"
    t.boolean  "cfc_status",         default: false
    t.string   "cfc_comment"
    t.float    "amount_spent"
    t.date     "last_signed_in_on"
    t.string   "vendor_ticket_id"
    t.string   "client_ticket_id"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
    t.string   "impact",             default: "Low"
    t.string   "target_service",     default: "FreeDNS"
    t.boolean  "random_domains",     default: false
  end

  create_table "nc_service_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "nc_services", force: :cascade do |t|
    t.integer  "nc_user_id"
    t.integer  "nc_service_type_id"
    t.integer  "status_ids",         default: [],              array: true
    t.string   "name"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
  end

  create_table "nc_users", force: :cascade do |t|
    t.string   "username"
    t.integer  "status_ids",   default: [],              array: true
    t.date     "signed_up_on"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  create_table "permissions", force: :cascade do |t|
    t.integer  "role_id"
    t.string   "subject_class"
    t.string   "actions",                    array: true
    t.integer  "subject_ids",                array: true
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "private_email_infos", force: :cascade do |t|
    t.integer  "abuse_report_id"
    t.boolean  "suspended",         default: false
    t.string   "reported_by"
    t.string   "warning_ticket_id"
    t.datetime "created_at",                        null: false
    t.datetime "updated_at",                        null: false
  end

  create_table "rbl_statuses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rbls", force: :cascade do |t|
    t.integer  "rbl_status_id"
    t.string   "name"
    t.string   "url"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
  end

  create_table "relation_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "report_assignment_types", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "report_assignments", force: :cascade do |t|
    t.integer  "reportable_id"
    t.string   "reportable_type"
    t.integer  "abuse_report_id"
    t.integer  "report_assignment_type_id"
    t.jsonb    "meta_data",                 default: {}
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "report_assignments", ["reportable_type", "reportable_id"], name: "index_report_assignments_on_reportable_type_and_reportable_id", using: :btree

  create_table "roles", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles_users", id: false, force: :cascade do |t|
    t.integer "role_id"
    t.integer "user_id"
  end

  create_table "sbl_infos", force: :cascade do |t|
    t.integer  "sbl_id"
    t.string   "ip_range"
    t.datetime "date"
    t.text     "info"
    t.boolean  "rokso"
    t.boolean  "active",            default: true
    t.boolean  "removal_requested"
    t.string   "complaint"
    t.boolean  "client_responded"
    t.text     "comment"
    t.datetime "created_at",                       null: false
    t.datetime "updated_at",                       null: false
  end

  create_table "service_statuses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "spammer_infos", force: :cascade do |t|
    t.integer  "abuse_report_id"
    t.integer  "registered_domains"
    t.integer  "abused_domains"
    t.integer  "locked_domains"
    t.integer  "abused_locked_domains"
    t.boolean  "cfc_status",            default: false
    t.string   "cfc_comment"
    t.float    "amount_spent"
    t.date     "last_signed_in_on"
    t.boolean  "responded_previously",  default: false
    t.string   "reference_ticket_id"
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  create_table "statuses", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  create_table "watched_domains", force: :cascade do |t|
    t.string   "name"
    t.string   "status",                  array: true
    t.text     "comment"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "whitelisted_addresses", force: :cascade do |t|
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
