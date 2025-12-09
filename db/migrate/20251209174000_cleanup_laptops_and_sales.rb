class CleanupLaptopsAndSales < ActiveRecord::Migration[7.1]
  def change
    remove_reference :sales, :laptop, foreign_key: true

    change_table :laptops, bulk: true do |t|
      t.remove :sku, :vendor, :brand, :model, :model_number, :serial_number,
               :status, :condition, :purchase_date, :purchase_price,
               :allocated_to_id, :last_service_date, :next_service_due, :notes
    end
  end
end
