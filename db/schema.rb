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

ActiveRecord::Schema.define(version: 20170607161227) do

  create_table "accounts", force: :cascade do |t|
    t.string   "name",        limit: 50,                                              null: false
    t.integer  "user_id",     limit: 4,                                               null: false
    t.decimal  "funds",                   precision: 10, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "currency_id", limit: 4
    t.string   "status",      limit: 255,                          default: "active", null: false
  end

  add_index "accounts", ["currency_id"], name: "index_accounts_on_currency_id", using: :btree
  add_index "accounts", ["status"], name: "index_accounts_on_status", using: :btree
  add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree

  create_table "aggregated_transactions", force: :cascade do |t|
    t.integer  "user_id",           limit: 4,                          null: false
    t.integer  "category_id",       limit: 4,                          null: false
    t.integer  "category_type_id",  limit: 4,                          null: false
    t.decimal  "amount",                      precision: 10, scale: 2, null: false
    t.datetime "period_started_at",                                    null: false
    t.datetime "period_ended_at",                                      null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "currency_id",       limit: 4
  end

  add_index "aggregated_transactions", ["category_id"], name: "index_aggregated_transactions_on_category_id", using: :btree
  add_index "aggregated_transactions", ["category_type_id"], name: "index_aggregated_transactions_on_category_type_id", using: :btree
  add_index "aggregated_transactions", ["currency_id"], name: "index_aggregated_transactions_on_currency_id", using: :btree
  add_index "aggregated_transactions", ["user_id"], name: "index_aggregated_transactions_on_user_id", using: :btree

  create_table "cash_flows", force: :cascade do |t|
    t.integer  "user_id",         limit: 4,                          null: false
    t.integer  "from_account_id", limit: 4,                          null: false
    t.integer  "to_account_id",   limit: 4,                          null: false
    t.decimal  "amount",                    precision: 10, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "initial_amount",            precision: 10, scale: 2
  end

  add_index "cash_flows", ["from_account_id"], name: "index_cash_flows_on_from_account_id", using: :btree
  add_index "cash_flows", ["to_account_id"], name: "index_cash_flows_on_to_account_id", using: :btree
  add_index "cash_flows", ["user_id"], name: "index_cash_flows_on_user_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.integer  "category_type_id", limit: 4
    t.integer  "user_id",          limit: 4
    t.boolean  "inactive",         limit: 1,   default: false
    t.datetime "updated_at"
  end

  add_index "categories", ["category_type_id"], name: "index_categories_on_category_type_id", using: :btree
  add_index "categories", ["updated_at"], name: "index_categories_on_updated_at", using: :btree
  add_index "categories", ["user_id"], name: "index_categories_on_user_id", using: :btree

  create_table "category_types", force: :cascade do |t|
    t.string "name", limit: 255
  end

  create_table "currencies", force: :cascade do |t|
    t.string   "name",       limit: 255, null: false
    t.string   "unit",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currencies", ["name"], name: "index_currencies_on_name", unique: true, using: :btree

  create_table "transactions", force: :cascade do |t|
    t.integer  "category_id", limit: 4
    t.decimal  "summ",                      precision: 10, scale: 2, default: 0.0, null: false
    t.text     "comment",     limit: 65535
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id",     limit: 4
    t.integer  "account_id",  limit: 4
  end

  add_index "transactions", ["account_id"], name: "index_transactions_on_account_id", using: :btree
  add_index "transactions", ["category_id"], name: "index_transactions_on_category_id", using: :btree
  add_index "transactions", ["user_id"], name: "index_transactions_on_user_id", using: :btree

  create_table "users", force: :cascade do |t|
    t.string   "email",                limit: 255, default: "", null: false
    t.string   "encrypted_password",   limit: 128, default: "", null: false
    t.string   "password_salt",        limit: 255, default: "", null: false
    t.string   "reset_password_token", limit: 255
    t.string   "remember_token",       limit: 255
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",        limit: 4,   default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",   limit: 255
    t.string   "last_sign_in_ip",      limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
