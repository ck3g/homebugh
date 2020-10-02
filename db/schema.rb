# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2020_09_30_183153) do

  create_table "accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", limit: 50, null: false
    t.integer "user_id", null: false
    t.decimal "funds", precision: 10, scale: 2, default: "0.0"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "currency_id"
    t.string "status", default: "active", null: false
    t.index ["currency_id"], name: "index_accounts_on_currency_id"
    t.index ["status"], name: "index_accounts_on_status"
    t.index ["user_id"], name: "index_accounts_on_user_id"
  end

  create_table "aggregated_transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "category_id", null: false
    t.integer "category_type_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "period_started_at", null: false
    t.datetime "period_ended_at", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "currency_id"
    t.index ["category_id"], name: "index_aggregated_transactions_on_category_id"
    t.index ["category_type_id"], name: "index_aggregated_transactions_on_category_type_id"
    t.index ["currency_id"], name: "index_aggregated_transactions_on_currency_id"
    t.index ["user_id"], name: "index_aggregated_transactions_on_user_id"
  end

  create_table "budgets", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "category_id", null: false
    t.integer "currency_id", null: false
    t.decimal "limit", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_budgets_on_category_id"
    t.index ["currency_id"], name: "index_budgets_on_currency_id"
    t.index ["user_id"], name: "index_budgets_on_user_id"
  end

  create_table "cash_flows", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "from_account_id", null: false
    t.integer "to_account_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal "initial_amount", precision: 10, scale: 2
    t.index ["from_account_id"], name: "index_cash_flows_on_from_account_id"
    t.index ["to_account_id"], name: "index_cash_flows_on_to_account_id"
    t.index ["user_id"], name: "index_cash_flows_on_user_id"
  end

  create_table "categories", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
    t.integer "category_type_id"
    t.integer "user_id"
    t.boolean "inactive", default: false
    t.datetime "updated_at"
    t.index ["category_type_id"], name: "index_categories_on_category_type_id"
    t.index ["updated_at"], name: "index_categories_on_updated_at"
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "category_types", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name"
  end

  create_table "currencies", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "name", null: false
    t.string "unit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["name"], name: "index_currencies_on_name", unique: true
  end

  create_table "recurring_payments", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "title", null: false
    t.integer "user_id", null: false
    t.integer "category_id", null: false
    t.integer "account_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "frequency_amount", null: false
    t.integer "frequency", default: 0, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["account_id"], name: "index_recurring_payments_on_account_id"
    t.index ["category_id"], name: "index_recurring_payments_on_category_id"
    t.index ["user_id"], name: "index_recurring_payments_on_user_id"
  end

  create_table "transactions", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.integer "category_id"
    t.decimal "summ", precision: 10, scale: 2, default: "0.0", null: false
    t.text "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "account_id"
    t.index ["account_id"], name: "index_transactions_on_account_id"
    t.index ["category_id"], name: "index_transactions_on_category_id"
    t.index ["user_id"], name: "index_transactions_on_user_id"
  end

  create_table "users", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", limit: 128, default: "", null: false
    t.string "password_salt", default: "", null: false
    t.string "reset_password_token"
    t.string "remember_token"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "reset_password_sent_at"
    t.string "access_token"
    t.boolean "demo_user", default: false
    t.index ["access_token"], name: "index_users_on_access_token", unique: true
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
