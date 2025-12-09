class CreateProductsAndEquipment < ActiveRecord::Migration[7.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.integer :category, null: false, default: 0
      t.string :sku, null: false
      t.string :serial_number, null: false
      t.string :vendor
      t.string :brand
      t.string :model
      t.string :model_number
      t.string :location
      t.integer :status, null: false, default: 0
      t.integer :condition, null: false, default: 0
      t.date :purchase_date
      t.decimal :purchase_price, precision: 12, scale: 2
      t.date :last_service_date
      t.date :next_service_due
      t.text :notes
      t.references :allocated_to, foreign_key: { to_table: :users }
      t.references :productable, polymorphic: true, null: false
      t.timestamps
    end

    add_index :products, :sku, unique: true
    add_index :products, :serial_number, unique: true
    add_index :products, :category
    add_index :products, :status

    create_table :mice do |t|
      t.string :connectivity
      t.integer :dpi
      t.integer :buttons
      t.string :color
      t.boolean :rechargeable
      t.timestamps
    end

    create_table :keyboards do |t|
      t.string :layout
      t.string :switch_type
      t.boolean :backlit
      t.string :connectivity
      t.boolean :wireless
      t.timestamps
    end

    create_table :servers do |t|
      t.string :cpu_model
      t.integer :cpu_count
      t.string :ram_size
      t.string :storage_capacity
      t.string :storage_type
      t.string :raid_level
      t.string :operating_system
      t.string :rack_units
      t.timestamps
    end

    create_table :desktop_pcs do |t|
      t.string :cpu
      t.string :ram_size
      t.string :storage_capacity
      t.string :storage_type
      t.string :gpu
      t.string :form_factor
      t.timestamps
    end
  end
end
