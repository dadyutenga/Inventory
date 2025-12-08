class CreateLaptops < ActiveRecord::Migration[8.1]
  def change
    create_table :laptops do |t|
      t.string :sku
      t.string :vendor
      t.string :brand
      t.string :model
      t.string :model_number
      t.string :serial_number
      t.date :purchase_date
      t.decimal :purchase_price
      t.integer :condition
      t.string :cpu
      t.string :cpu_generation
      t.string :gpu
      t.string :ram_size
      t.string :ram_type
      t.string :storage_capacity
      t.string :storage_type
      t.string :screen_size
      t.string :screen_resolution
      t.string :display_type
      t.string :keyboard_type
      t.boolean :keyboard_backlight
      t.string :battery_capacity
      t.boolean :webcam
      t.boolean :microphone
      t.string :wifi_type
      t.string :bluetooth_version
      t.text :ports
      t.string :weight
      t.string :operating_system
      t.string :license_key
      t.integer :status, default: 0, null: false
      t.references :allocated_to, foreign_key: { to_table: :users }
      t.date :last_service_date
      t.date :next_service_due
      t.text :notes

      t.timestamps
    end
    add_index :laptops, :serial_number, unique: true
  end
end
