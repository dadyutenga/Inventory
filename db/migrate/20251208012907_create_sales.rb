class CreateSales < ActiveRecord::Migration[8.1]
  def change
    create_table :sales do |t|
      t.references :laptop, null: false, foreign_key: true
      t.references :sold_by, null: false, foreign_key: { to_table: :users }
      t.string :sold_to, null: false
      t.datetime :sold_at, null: false
      t.decimal :sale_price, precision: 10, scale: 2, null: false
      t.string :invoice_ref

      t.timestamps
    end
  end
end
