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

ActiveRecord::Schema.define(version: 20150914170421) do

  create_table "admins", force: :cascade do |t|
    t.string   "email",              limit: 255, default: "", null: false
    t.string   "encrypted_password", limit: 255, default: "", null: false
    t.integer  "sign_in_count",      limit: 4,   default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip", limit: 255
    t.string   "last_sign_in_ip",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "admins", ["email"], name: "index_admins_on_email", unique: true, using: :btree

  create_table "availabilities", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "rent_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "availabilities", ["rent_id"], name: "index_availabilities_on_rent_id", using: :btree

  create_table "booking_times", force: :cascade do |t|
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer  "booking_id", limit: 4
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.boolean  "paid",       limit: 1, default: false
  end

  add_index "booking_times", ["booking_id"], name: "index_booking_times_on_booking_id", using: :btree

  create_table "bookings", force: :cascade do |t|
    t.string   "name",          limit: 50
    t.string   "license",       limit: 9
    t.string   "phone",         limit: 12
    t.decimal  "price",                    precision: 10, scale: 4
    t.decimal  "reduced_price",            precision: 10, scale: 4
    t.integer  "user_id",       limit: 4
    t.integer  "carpark_id",    limit: 4
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
  end

  create_table "carparks", force: :cascade do |t|
    t.text     "description",   limit: 65535
    t.integer  "number",        limit: 8
    t.decimal  "profit",                      precision: 10, scale: 4
    t.decimal  "price",                       precision: 10, scale: 4
    t.decimal  "reduced_price",               precision: 10, scale: 4
    t.integer  "garage_id",     limit: 4
    t.integer  "user_id",       limit: 4
    t.datetime "created_at",                                           null: false
    t.datetime "updated_at",                                           null: false
  end

  create_table "charges", force: :cascade do |t|
    t.integer  "booking_time_id", limit: 4
    t.datetime "paid_at"
    t.datetime "created_at",                null: false
    t.datetime "updated_at",                null: false
  end

  add_index "charges", ["booking_time_id"], name: "index_charges_on_booking_time_id", using: :btree

  create_table "garages", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "address",     limit: 255
    t.string   "city",        limit: 255
    t.integer  "province_id", limit: 4
    t.string   "phone",       limit: 255
    t.integer  "postal_code", limit: 4
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
    t.float    "latitude",    limit: 24
    t.float    "longitude",   limit: 24
  end

  create_table "gate_tasks", force: :cascade do |t|
    t.integer  "booking_time_id", limit: 4
    t.string   "user_phone",      limit: 12
    t.string   "garage_phone",    limit: 12
    t.datetime "time"
    t.integer  "action",          limit: 4,  default: 0
    t.datetime "sent_at"
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "gate_tasks", ["booking_time_id"], name: "index_gate_tasks_on_booking_time_id", using: :btree

  create_table "photos", force: :cascade do |t|
    t.integer  "number",             limit: 4
    t.datetime "created_at",                     null: false
    t.datetime "updated_at",                     null: false
    t.string   "image_file_name",    limit: 255
    t.string   "image_content_type", limit: 255
    t.integer  "image_file_size",    limit: 4
    t.datetime "image_updated_at"
    t.integer  "photoble_id",        limit: 4
    t.string   "photoble_type",      limit: 255
  end

  add_index "photos", ["photoble_type", "photoble_id"], name: "index_photos_on_photoble_type_and_photoble_id", using: :btree

  create_table "provinces", force: :cascade do |t|
    t.string "name", limit: 50
  end

  create_table "rents", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "carpark_id", limit: 4
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.integer  "user_id",          limit: 4
    t.integer  "movement_type",    limit: 4,                           default: 0
    t.string   "ip_address",       limit: 255
    t.string   "transaction_type", limit: 255
    t.string   "transaction_id",   limit: 255
    t.string   "payer_id",         limit: 255
    t.string   "currency",         limit: 255
    t.string   "status",           limit: 255
    t.decimal  "fee",                          precision: 8, scale: 2
    t.integer  "amount",           limit: 4
    t.string   "description",      limit: 255
    t.string   "token",            limit: 255
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
  end

  add_index "transactions", ["user_id"], name: "index_transactions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,                          default: "",  null: false
    t.string   "encrypted_password",     limit: 255,                          default: "",  null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,                            default: 0,   null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.string   "confirmation_token",     limit: 255
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email",      limit: 255
    t.integer  "failed_attempts",        limit: 4,                            default: 0,   null: false
    t.string   "unlock_token",           limit: 255
    t.datetime "locked_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "balance",                            precision: 10, scale: 2, default: 0.0
    t.string   "name",                   limit: 50
    t.string   "surname",                limit: 50
    t.string   "dni",                    limit: 9
    t.string   "phone",                  limit: 12
    t.string   "license",                limit: 9
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

  add_foreign_key "availabilities", "rents"
  add_foreign_key "booking_times", "bookings"
  add_foreign_key "charges", "booking_times"
  add_foreign_key "gate_tasks", "booking_times"
  add_foreign_key "transactions", "users"
end
