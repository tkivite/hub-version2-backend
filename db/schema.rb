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

ActiveRecord::Schema.define(version: 2020_09_16_125756) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"
  enable_extension "uuid-ossp"

  create_table "assignments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "assigned_by"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "user_id"
    t.uuid "role_id"
    t.index ["role_id"], name: "index_assignments_on_role_id"
    t.index ["user_id"], name: "index_assignments_on_user_id"
  end

  create_table "contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "title"
    t.string "name"
    t.string "email"
    t.string "mobile"
    t.string "extra_details"
    t.uuid "record_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "partners", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "year_of_incorporation"
    t.text "speciality"
    t.integer "no_of_branches"
    t.string "payment_terms"
    t.integer "credit_duration_in_days"
    t.string "core_id"
    t.string "location"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "creator_id"
    t.uuid "account_manager_id"
    t.index ["account_manager_id"], name: "index_partners_on_account_manager_id"
    t.index ["creator_id"], name: "index_partners_on_creator_id"
  end

  create_table "reset_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "token"
    t.integer "verification_code"
    t.date "expiration"
    t.boolean "used"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "user_id"
    t.index ["user_id"], name: "index_reset_tokens_on_user_id"
  end

  create_table "roles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.integer "role_type"
    t.float "rank"
    t.text "permissions", default: [], array: true
    t.uuid "created_by"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "store_accounts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "type"
    t.string "channel"
    t.string "account_type"
    t.string "institution"
    t.string "account_name"
    t.string "account_number"
    t.string "payer_identity"
    t.string "other_details"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "stores_id"
    t.index ["stores_id"], name: "index_store_accounts_on_stores_id"
  end

  create_table "stores", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "store_key"
    t.integer "target"
    t.string "location"
    t.integer "no_of_employess"
    t.float "monthly_revenue"
    t.string "city"
    t.integer "core_id"
    t.string "country"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "partner_id"
    t.uuid "creator_id"
    t.index ["creator_id"], name: "index_stores_on_creator_id"
    t.index ["partner_id"], name: "index_stores_on_partner_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "firstname"
    t.string "othernames"
    t.string "gender"
    t.string "email"
    t.string "password_digest"
    t.string "mobile"
    t.uuid "created_by"
    t.boolean "is_admin"
    t.datetime "last_login_time"
    t.boolean "logged_in"
    t.integer "status"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.uuid "store_id"
    t.index ["store_id"], name: "index_users_on_store_id"
  end

  add_foreign_key "assignments", "roles"
  add_foreign_key "assignments", "users"
  add_foreign_key "partners", "users", column: "account_manager_id"
  add_foreign_key "partners", "users", column: "creator_id"
  add_foreign_key "reset_tokens", "users"
  add_foreign_key "store_accounts", "stores", column: "stores_id"
  add_foreign_key "stores", "partners"
  add_foreign_key "stores", "users", column: "creator_id"
  add_foreign_key "users", "stores"
end
