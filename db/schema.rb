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

ActiveRecord::Schema[8.1].define(version: 2025_12_09_190000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "activity_logs", force: :cascade do |t|
    t.string "action_type", null: false
    t.datetime "created_at", null: false
    t.bigint "entity_id", null: false
    t.string "entity_type", null: false
    t.string "ip_address"
    t.jsonb "new_values"
    t.jsonb "old_values"
    t.datetime "updated_at", null: false
    t.text "user_agent"
    t.bigint "user_id", null: false
    t.index ["action_type"], name: "index_activity_logs_on_action_type"
    t.index ["created_at"], name: "index_activity_logs_on_created_at"
    t.index ["entity_type", "entity_id"], name: "index_activity_logs_on_entity_type_and_entity_id"
    t.index ["user_id"], name: "index_activity_logs_on_user_id"
  end

  create_table "blacklisted_tokens", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "token_digest", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_blacklisted_tokens_on_expires_at"
    t.index ["token_digest"], name: "index_blacklisted_tokens_on_token_digest", unique: true
  end

  create_table "desktop_pcs", force: :cascade do |t|
    t.string "cpu"
    t.datetime "created_at", null: false
    t.string "form_factor"
    t.string "gpu"
    t.string "ram_size"
    t.string "storage_capacity"
    t.string "storage_type"
    t.datetime "updated_at", null: false
  end

  create_table "keyboards", force: :cascade do |t|
    t.boolean "backlit"
    t.string "connectivity"
    t.datetime "created_at", null: false
    t.string "layout"
    t.string "switch_type"
    t.datetime "updated_at", null: false
    t.boolean "wireless"
  end

  create_table "laptops", force: :cascade do |t|
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
  end

  create_table "mice", force: :cascade do |t|
    t.integer "buttons"
    t.string "color"
    t.string "connectivity"
    t.datetime "created_at", null: false
    t.integer "dpi"
    t.boolean "rechargeable"
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.bigint "allocated_to_id"
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
    t.bigint "productable_id", null: false
    t.string "productable_type", null: false
    t.date "purchase_date"
    t.decimal "purchase_price", precision: 12, scale: 2
    t.string "serial_number", null: false
    t.string "sku", null: false
    t.integer "status", default: 0, null: false
    t.datetime "updated_at", null: false
    t.string "vendor"
    t.index ["allocated_to_id"], name: "index_products_on_allocated_to_id"
    t.index ["category"], name: "index_products_on_category"
    t.index ["productable_type", "productable_id"], name: "index_products_on_productable"
    t.index ["serial_number"], name: "index_products_on_serial_number", unique: true
    t.index ["sku"], name: "index_products_on_sku", unique: true
    t.index ["status"], name: "index_products_on_status"
  end

  create_table "sales", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "invoice_ref"
    t.bigint "product_id", null: false
    t.decimal "sale_price", precision: 10, scale: 2, null: false
    t.datetime "sold_at", null: false
    t.bigint "sold_by_id", null: false
    t.string "sold_to", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_sales_on_product_id"
    t.index ["sold_by_id"], name: "index_sales_on_sold_by_id"
  end

  create_table "servers", force: :cascade do |t|
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
  end

  create_table "users", force: :cascade do |t|
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
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activity_logs", "users"
  add_foreign_key "products", "users", column: "allocated_to_id"
  add_foreign_key "sales", "products"
  add_foreign_key "sales", "users", column: "sold_by_id"
end
