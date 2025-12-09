class MigrateLaptopsToProducts < ActiveRecord::Migration[7.1]
  class Product < ApplicationRecord
    self.table_name = "products"
  end

  class Laptop < ApplicationRecord
    self.table_name = "laptops"
  end

  class Sale < ApplicationRecord
    self.table_name = "sales"
  end

  def up
    add_reference :sales, :product, foreign_key: true

    Product.reset_column_information
    Laptop.reset_column_information
    Sale.reset_column_information

    Laptop.find_each do |laptop|
      name = [ laptop.brand, laptop.model ].compact.join(" ").presence || laptop.model || laptop.serial_number || "Laptop"

      product = Product.create!(
        name: name,
        category: 0, # laptop
        sku: laptop.sku,
        serial_number: laptop.serial_number,
        vendor: laptop.vendor,
        brand: laptop.brand,
        model: laptop.model,
        model_number: laptop.model_number,
        location: nil,
        status: laptop.status || 0,
        condition: laptop.condition || 0,
        purchase_date: laptop.purchase_date,
        purchase_price: laptop.purchase_price,
        last_service_date: laptop.last_service_date,
        next_service_due: laptop.next_service_due,
        notes: laptop.notes,
        allocated_to_id: laptop.allocated_to_id,
        productable: laptop
      )

      Sale.where(laptop_id: laptop.id).update_all(product_id: product.id)

      execute <<~SQL.squish
        UPDATE active_storage_attachments
        SET record_type = 'Product', record_id = #{product.id}
        WHERE record_type = 'Laptop' AND record_id = #{laptop.id}
      SQL
    end

    change_column_null :sales, :product_id, false
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Products are required for the new polymorphic structure"
  end
end
