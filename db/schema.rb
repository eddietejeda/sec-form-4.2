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

ActiveRecord::Schema.define(version: 2021_11_14_181349) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "baby_names", id: false, force: :cascade do |t|
    t.decimal "year", precision: 4
    t.string "gender"
    t.string "ethnicity"
    t.string "name"
    t.decimal "count"
    t.decimal "rank"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "ticker", null: false
    t.string "cik"
    t.jsonb "data", default: "{}", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "statements", force: :cascade do |t|
    t.integer "company_id", null: false
    t.datetime "fiscal_date", precision: 6
    t.jsonb "income_statement", default: "{}", null: false
    t.jsonb "balance_sheet", default: "{}", null: false
    t.jsonb "cash_flow", default: "{}", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "stocks", force: :cascade do |t|
    t.string "ticker", null: false
    t.datetime "date", null: false
    t.money "price", scale: 2, null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "transactions", force: :cascade do |t|
    t.integer "company_id", null: false
    t.string "document_url", null: false
    t.datetime "document_date"
    t.money "amount", scale: 2
    t.jsonb "data", default: "{}", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["document_url"], name: "index_transactions_on_document_url"
  end

end
