# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_07_03_154345) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bikes", force: :cascade do |t|
    t.bigint "station_id", null: false
    t.string "brand"
    t.decimal "total_kms", precision: 10, scale: 1
    t.decimal "pricing", precision: 10, scale: 2
    t.integer "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["station_id"], name: "index_bikes_on_station_id"
  end

  create_table "counties", force: :cascade do |t|
    t.string "name"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "county_providers", force: :cascade do |t|
    t.bigint "county_id", null: false
    t.bigint "provider_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["county_id"], name: "index_county_providers_on_county_id"
    t.index ["provider_id"], name: "index_county_providers_on_provider_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "username"
    t.decimal "balance", precision: 10, scale: 2, default: "0.0"
    t.string "id_card_number"
    t.integer "status", default: 0
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "payments", force: :cascade do |t|
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.integer "method", null: false
    t.bigint "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_payments_on_customer_id"
  end

  create_table "providers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "reservations", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.bigint "bike_id", null: false
    t.index ["bike_id"], name: "index_reservations_on_bike_id"
    t.index ["customer_id"], name: "index_reservations_on_customer_id"
    t.index ["status"], name: "index_reservations_on_status"
  end

  create_table "rides", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.bigint "bike_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.datetime "expected_end_time"
    t.decimal "price"
    t.bigint "origin_station_id", null: false
    t.bigint "destination_station_id"
    t.bigint "expected_destination_station_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bike_id"], name: "index_rides_on_bike_id"
    t.index ["customer_id"], name: "index_rides_on_customer_id"
    t.index ["destination_station_id"], name: "index_rides_on_destination_station_id"
    t.index ["expected_destination_station_id"], name: "index_rides_on_expected_destination_station_id"
    t.index ["origin_station_id"], name: "index_rides_on_origin_station_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "stations", force: :cascade do |t|
    t.bigint "county_id", null: false
    t.string "name"
    t.decimal "latitude", precision: 10, scale: 6
    t.decimal "longitude", precision: 10, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "max_capacity"
    t.index ["county_id"], name: "index_stations_on_county_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "bikes", "stations"
  add_foreign_key "county_providers", "counties"
  add_foreign_key "county_providers", "providers"
  add_foreign_key "customers", "users"
  add_foreign_key "payments", "customers"
  add_foreign_key "reservations", "bikes"
  add_foreign_key "reservations", "customers"
  add_foreign_key "rides", "bikes"
  add_foreign_key "rides", "customers"
  add_foreign_key "rides", "stations", column: "destination_station_id"
  add_foreign_key "rides", "stations", column: "expected_destination_station_id"
  add_foreign_key "rides", "stations", column: "origin_station_id"
  add_foreign_key "sessions", "users"
  add_foreign_key "stations", "counties"
end
