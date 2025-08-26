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

ActiveRecord::Schema[8.0].define(version: 2025_08_26_173419) do
  create_table "active_storage_attachments", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "baby_foods", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "child_id", null: false
    t.datetime "fed_at"
    t.integer "amount"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["child_id"], name: "index_baby_foods_on_child_id"
    t.index ["user_id"], name: "index_baby_foods_on_user_id"
  end

  create_table "baths", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "child_id", null: false
    t.datetime "bathed_at"
    t.string "bath_type"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["child_id"], name: "index_baths_on_child_id"
    t.index ["user_id"], name: "index_baths_on_user_id"
  end

  create_table "bottles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "amount"
    t.datetime "given_at"
    t.text "memo"
    t.bigint "child_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["child_id"], name: "index_bottles_on_child_id"
    t.index ["user_id"], name: "index_bottles_on_user_id"
  end

  create_table "children", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name"
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "gender"
    t.integer "daily_bottle_goal", default: 600, null: false
    t.integer "daily_hydration_goal", default: 800, null: false
    t.integer "daily_baby_food_goal", default: 3, null: false
  end

  create_table "diapers", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.boolean "pee"
    t.boolean "poop"
    t.datetime "changed_at"
    t.text "memo"
    t.bigint "child_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["child_id"], name: "index_diapers_on_child_id"
    t.index ["user_id"], name: "index_diapers_on_user_id"
  end

  create_table "feeds", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "child_id", null: false
    t.integer "left_time"
    t.integer "right_time"
    t.datetime "fed_at"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["child_id"], name: "index_feeds_on_child_id"
    t.index ["user_id"], name: "index_feeds_on_user_id"
  end

  create_table "hydrations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "drink_type"
    t.datetime "fed_at"
    t.text "memo"
    t.bigint "child_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "amount"
    t.bigint "user_id"
    t.index ["child_id"], name: "index_hydrations_on_child_id"
    t.index ["user_id"], name: "index_hydrations_on_user_id"
  end

  create_table "notifications", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "child_id", null: false
    t.string "target_type"
    t.bigint "target_id"
    t.integer "notification_kind", default: 0, null: false
    t.string "title", null: false
    t.text "message"
    t.boolean "read", default: false, null: false
    t.datetime "delivered_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id", "notification_kind"], name: "index_notifications_on_child_id_and_notification_kind"
    t.index ["child_id"], name: "index_notifications_on_child_id"
    t.index ["target_type", "target_id"], name: "index_notifications_on_target_type_and_target_id"
    t.index ["user_id", "read"], name: "index_notifications_on_user_id_and_read"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "schedules", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "child_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time"
    t.string "title"
    t.boolean "all_day", default: false, null: false
    t.string "repeat", default: "none"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["child_id"], name: "index_schedules_on_child_id"
    t.index ["user_id"], name: "index_schedules_on_user_id"
  end

  create_table "sleep_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "child_id", null: false
    t.datetime "start_time"
    t.datetime "end_time"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["child_id"], name: "index_sleep_records_on_child_id"
    t.index ["user_id"], name: "index_sleep_records_on_user_id"
  end

  create_table "temperatures", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "child_id", null: false
    t.datetime "measured_at"
    t.decimal "temperature", precision: 3, scale: 1
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["child_id"], name: "index_temperatures_on_child_id"
    t.index ["user_id"], name: "index_temperatures_on_user_id"
  end

  create_table "user_children", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "child_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["child_id"], name: "index_user_children_on_child_id"
    t.index ["user_id", "child_id"], name: "index_user_children_on_user_id_and_child_id", unique: true
    t.index ["user_id"], name: "index_user_children_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "vaccinations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "child_id", null: false
    t.datetime "vaccinated_at"
    t.string "vaccine_name"
    t.text "memo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["child_id"], name: "index_vaccinations_on_child_id"
    t.index ["user_id"], name: "index_vaccinations_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "baby_foods", "children"
  add_foreign_key "baby_foods", "users"
  add_foreign_key "baths", "children"
  add_foreign_key "baths", "users"
  add_foreign_key "bottles", "children"
  add_foreign_key "bottles", "users"
  add_foreign_key "diapers", "children"
  add_foreign_key "diapers", "users"
  add_foreign_key "feeds", "children"
  add_foreign_key "feeds", "users"
  add_foreign_key "hydrations", "children"
  add_foreign_key "hydrations", "users"
  add_foreign_key "notifications", "children"
  add_foreign_key "notifications", "users"
  add_foreign_key "schedules", "children"
  add_foreign_key "schedules", "users"
  add_foreign_key "sleep_records", "children"
  add_foreign_key "sleep_records", "users"
  add_foreign_key "temperatures", "children"
  add_foreign_key "temperatures", "users"
  add_foreign_key "user_children", "children"
  add_foreign_key "user_children", "users"
  add_foreign_key "vaccinations", "children"
  add_foreign_key "vaccinations", "users"
end
