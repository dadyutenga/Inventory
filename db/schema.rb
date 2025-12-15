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

ActiveRecord::Schema[8.1].define(version: 2025_12_15_064618) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "active_storage_attachments", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.uuid "record_id"
    t.string "record_type", null: false
    t.index ["id"], name: "index_active_storage_attachments_on_id", unique: true
  end

  create_table "active_storage_blobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["id"], name: "index_active_storage_blobs_on_id", unique: true
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "blob_id"
    t.string "variation_digest", null: false
    t.index ["id"], name: "index_active_storage_variant_records_on_id", unique: true
  end

  create_table "activity_logs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "action_type", null: false
    t.datetime "created_at", null: false
    t.uuid "entity_id"
    t.string "entity_type", null: false
    t.string "ip_address"
    t.jsonb "new_values"
    t.jsonb "old_values"
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.uuid "user_id"
    t.index ["action_type"], name: "index_activity_logs_on_action_type"
    t.index ["created_at"], name: "index_activity_logs_on_created_at"
    t.index ["id"], name: "index_activity_logs_on_id", unique: true
  end

  create_table "blacklisted_tokens", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_blacklisted_tokens_on_expires_at"
    t.index ["id"], name: "index_blacklisted_tokens_on_id", unique: true
    t.index ["token_digest"], name: "index_blacklisted_tokens_on_token_digest", unique: true
  end

  create_table "desktop_pcs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "cpu"
    t.datetime "created_at", null: false
    t.string "form_factor"
    t.string "gpu"
    t.string "ram_size"
    t.string "storage_capacity"
    t.string "storage_type"
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_desktop_pcs_on_id", unique: true
  end

  create_table "keyboards", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "backlit"
    t.string "connectivity"
    t.datetime "created_at", null: false
    t.string "layout"
    t.string "switch_type"
    t.datetime "updated_at", null: false
    t.boolean "wireless"
    t.index ["id"], name: "index_keyboards_on_id", unique: true
  end

  create_table "laptops", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "battery_capacity"
    t.string "bluetooth_version"
    t.string "cpu"
    t.string "cpu_generation"
    t.datetime "created_at", null: false
    t.string "display_type"
    t.string "gpu"
    t.boolean "keyboard_backlight"
    t.string "keyboard_type"
    t.string "license_key"
    t.boolean "microphone"
    t.string "operating_system"
    t.text "ports"
    t.string "ram_size"
    t.string "ram_type"
    t.string "screen_resolution"
    t.string "screen_size"
    t.string "storage_capacity"
    t.string "storage_type"
    t.datetime "updated_at", null: false
    t.boolean "webcam"
    t.string "weight"
    t.string "wifi_type"
    t.index ["id"], name: "index_laptops_on_id", unique: true
  end

  create_table "mice", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "buttons"
    t.string "color"
    t.string "connectivity"
    t.datetime "created_at", null: false
    t.integer "dpi"
    t.boolean "rechargeable"
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_mice_on_id", unique: true
  end

  create_table "products", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "allocated_to_id"
    t.string "brand"
    t.integer "category", default: 0, null: false
    t.integer "condition", default: 0, null: false
    t.datetime "created_at", null: false
    t.date "last_service_date"
    t.string "location"
    t.string "model"
    t.string "model_number"
    t.string "name", null: false
    t.date "next_service_due"
    t.text "notes"
    t.uuid "productable_id"
    t.string "productable_type", null: false
    t.date "purchase_date"
    t.decimal "purchase_price", precision: 12, scale: 2
    t.string "serial_number", null: false
    t.string "sku", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "vendor"
    t.index ["category"], name: "index_products_on_category"
    t.index ["id"], name: "index_products_on_id", unique: true
    t.index ["serial_number"], name: "index_products_on_serial_number", unique: true
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["status"], name: "index_products_on_status"
  end

  create_table "sales", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "invoice_ref"
    t.uuid "product_id"
    t.decimal "sale_price", precision: 10, scale: 2, null: false
    t.datetime "sold_at", null: false
    t.uuid "sold_by_id"
    t.string "sold_to", null: false
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_sales_on_id", unique: true
  end

  create_table "servers", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.integer "cpu_count"
    t.string "cpu_model"
    t.datetime "created_at", null: false
    t.string "operating_system"
    t.string "rack_units"
    t.string "raid_level"
    t.string "ram_size"
    t.string "storage_capacity"
    t.string "storage_type"
    t.datetime "updated_at", null: false
    t.index ["id"], name: "index_servers_on_id", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.string "password_digest"
    t.datetime "remember_created_at"
    t.datetime "reset_password_sent_at"
    t.string "reset_password_token"
    t.integer "role", default: 0, null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["id"], name: "index_users_on_id", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "products", "users", column: "allocated_to_id"
  add_foreign_key "sales", "products"
  add_foreign_key "sales", "users", column: "sold_by_id"
end
