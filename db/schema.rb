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

ActiveRecord::Schema.define(version: 20141206092752) do

  create_table "accounts", force: true do |t|
    t.string   "name",        limit: 50,                                        null: false
    t.integer  "user_id",                                                       null: false
    t.decimal  "funds",                  precision: 10, scale: 2, default: 0.0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "currency_id"
  end

  add_index "accounts", ["currency_id"], name: "index_accounts_on_currency_id", using: :btree
  add_index "accounts", ["user_id"], name: "index_accounts_on_user_id", using: :btree

  create_table "aggregated_transactions", force: true do |t|
    t.integer  "user_id",                                    null: false
    t.integer  "category_id",                                null: false
    t.integer  "category_type_id",                           null: false
    t.decimal  "amount",            precision: 10, scale: 2, null: false
    t.datetime "period_started_at",                          null: false
    t.datetime "period_ended_at",                            null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "aggregated_transactions", ["category_id"], name: "index_aggregated_transactions_on_category_id", using: :btree
  add_index "aggregated_transactions", ["category_type_id"], name: "index_aggregated_transactions_on_category_type_id", using: :btree
  add_index "aggregated_transactions", ["user_id"], name: "index_aggregated_transactions_on_user_id", using: :btree

  create_table "cash_flows", force: true do |t|
    t.integer  "user_id",                                  null: false
    t.integer  "from_account_id",                          null: false
    t.integer  "to_account_id",                            null: false
    t.decimal  "amount",          precision: 10, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "cash_flows", ["from_account_id"], name: "index_cash_flows_on_from_account_id", using: :btree
  add_index "cash_flows", ["to_account_id"], name: "index_cash_flows_on_to_account_id", using: :btree
  add_index "cash_flows", ["user_id"], name: "index_cash_flows_on_user_id", using: :btree

  create_table "categories", force: true do |t|
    t.string  "name"
    t.integer "category_type_id"
    t.integer "user_id"
    t.boolean "inactive",         default: false
  end

  add_index "categories", ["category_type_id"], name: "index_categories_on_category_type_id", using: :btree
  add_index "categories", ["user_id"], name: "index_categories_on_user_id", using: :btree

  create_table "category_types", force: true do |t|
    t.string "name"
  end

  create_table "currencies", force: true do |t|
    t.string   "name",       null: false
    t.string   "unit"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "currencies", ["name"], name: "index_currencies_on_name", unique: true, using: :btree

  create_table "transactions", force: true do |t|
    t.integer  "category_id"
    t.decimal  "summ",        precision: 10, scale: 2, default: 0.0, null: false
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "account_id"
  end

  add_index "transactions", ["account_id"], name: "index_transactions_on_account_id", using: :btree
  add_index "transactions", ["category_id"], name: "index_transactions_on_category_id", using: :btree
  add_index "transactions", ["user_id"], name: "index_transactions_on_user_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                            default: "", null: false
    t.string   "encrypted_password",   limit: 128, default: "", null: false
    t.string   "password_salt",                    default: "", null: false
    t.string   "reset_password_token"
    t.string   "remember_token"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                    default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
