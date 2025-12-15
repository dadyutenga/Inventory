class ConvertAllTablesToUuid < ActiveRecord::Migration[8.1]
  def up
    # Enable pgcrypto extension for UUID generation
    enable_extension 'pgcrypto' unless extension_enabled?('pgcrypto')

    # Convert users table
    add_column :users, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_index :users, :uuid, unique: true

    # Update foreign keys that reference users
    add_column :products, :allocated_to_uuid, :uuid
    add_column :sales, :sold_by_uuid, :uuid
    add_column :activity_logs, :user_uuid, :uuid

    # Copy user ID data
    execute <<~SQL
      UPDATE products SET allocated_to_uuid = (SELECT uuid FROM users WHERE users.id = products.allocated_to_id);
      UPDATE sales SET sold_by_uuid = (SELECT uuid FROM users WHERE users.id = sales.sold_by_id);
      UPDATE activity_logs SET user_uuid = (SELECT uuid FROM users WHERE users.id = activity_logs.user_id);
    SQL

    # Convert products table
    add_column :products, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_index :products, :uuid, unique: true

    # Update foreign keys that reference products
    add_column :sales, :product_uuid, :uuid
    add_column :activity_logs, :entity_uuid, :uuid

    # Copy product ID data
    execute <<~SQL
      UPDATE sales SET product_uuid = (SELECT uuid FROM products WHERE products.id = sales.product_id);
      UPDATE activity_logs SET entity_uuid = (SELECT uuid FROM products WHERE products.id = activity_logs.entity_id AND activity_logs.entity_type = 'Product');
    SQL

    # Convert polymorphic tables (laptops, mice, keyboards, servers, desktop_pcs)
    %w[laptops mice keyboards servers desktop_pcs].each do |table|
      add_column table, :uuid, :uuid, default: 'gen_random_uuid()', null: false
      add_index table, :uuid, unique: true
    end

    # Add new productable_uuid column to products
    add_column :products, :productable_uuid, :uuid

    # Update products.productable_uuid to point to new UUIDs
    %w[laptops mice keyboards servers desktop_pcs].each do |table|
      execute <<~SQL
        UPDATE products SET productable_uuid = (
          SELECT #{table}.uuid FROM #{table}#{' '}
          WHERE #{table}.id = products.productable_id#{' '}
          AND products.productable_type = '#{table.singularize.camelize}'
        ) WHERE products.productable_type = '#{table.singularize.camelize}';
      SQL
    end

    # Convert sales table
    add_column :sales, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_index :sales, :uuid, unique: true

    # Convert activity_logs table
    add_column :activity_logs, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_index :activity_logs, :uuid, unique: true

    # Convert blacklisted_tokens table
    add_column :blacklisted_tokens, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_index :blacklisted_tokens, :uuid, unique: true

    # Convert Active Storage tables
    add_column :active_storage_blobs, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_index :active_storage_blobs, :uuid, unique: true

    add_column :active_storage_attachments, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_column :active_storage_attachments, :blob_uuid, :uuid
    add_column :active_storage_attachments, :record_uuid, :uuid
    add_index :active_storage_attachments, :uuid, unique: true

    # Update Active Storage foreign keys
    execute <<~SQL
      UPDATE active_storage_attachments SET blob_uuid = (
        SELECT uuid FROM active_storage_blobs WHERE active_storage_blobs.id = active_storage_attachments.blob_id
      );
      UPDATE active_storage_attachments SET record_uuid = (
        SELECT uuid FROM products WHERE products.id = active_storage_attachments.record_id#{' '}
        AND active_storage_attachments.record_type = 'Product'
      );
    SQL

    add_column :active_storage_variant_records, :uuid, :uuid, default: 'gen_random_uuid()', null: false
    add_column :active_storage_variant_records, :blob_uuid, :uuid
    add_index :active_storage_variant_records, :uuid, unique: true

    execute <<~SQL
      UPDATE active_storage_variant_records SET blob_uuid = (
        SELECT uuid FROM active_storage_blobs WHERE active_storage_blobs.id = active_storage_variant_records.blob_id
      );
    SQL

    # Now replace primary keys and foreign keys

    # Drop existing foreign key constraints first
    remove_foreign_key :sales, :users if foreign_key_exists?(:sales, :users)
    remove_foreign_key :products, :users if foreign_key_exists?(:products, :users)
    remove_foreign_key :activity_logs, :users if foreign_key_exists?(:activity_logs, :users)
    remove_foreign_key :sales, :products if foreign_key_exists?(:sales, :products)
    remove_foreign_key :active_storage_attachments, :active_storage_blobs if foreign_key_exists?(:active_storage_attachments, :active_storage_blobs)
    remove_foreign_key :active_storage_variant_records, :active_storage_blobs if foreign_key_exists?(:active_storage_variant_records, :active_storage_blobs)

    # Users table
    change_table :users do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute 'ALTER TABLE users ADD PRIMARY KEY (id);'

    change_table :products do |t|
      t.remove :id
      t.rename :uuid, :id
      t.remove :productable_id
      t.rename :productable_uuid, :productable_id
      t.remove :allocated_to_id
      t.rename :allocated_to_uuid, :allocated_to_id
    end
    execute 'ALTER TABLE products ADD PRIMARY KEY (id);'

    change_table :sales do |t|
      t.remove :id
      t.rename :uuid, :id
      t.remove :product_id, :sold_by_id
      t.rename :product_uuid, :product_id
      t.rename :sold_by_uuid, :sold_by_id
    end
    execute 'ALTER TABLE sales ADD PRIMARY KEY (id);'

    change_table :activity_logs do |t|
      t.remove :id
      t.rename :uuid, :id
      t.remove :user_id, :entity_id
      t.rename :user_uuid, :user_id
      t.rename :entity_uuid, :entity_id
    end
    execute 'ALTER TABLE activity_logs ADD PRIMARY KEY (id);'

    change_table :blacklisted_tokens do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute 'ALTER TABLE blacklisted_tokens ADD PRIMARY KEY (id);'

    # Convert polymorphic tables
    %w[laptops mice keyboards servers desktop_pcs].each do |table|
      change_table table do |t|
        t.remove :id
        t.rename :uuid, :id
      end
      execute "ALTER TABLE #{table} ADD PRIMARY KEY (id);"
    end

    # Convert Active Storage tables
    change_table :active_storage_blobs do |t|
      t.remove :id
      t.rename :uuid, :id
    end
    execute 'ALTER TABLE active_storage_blobs ADD PRIMARY KEY (id);'

    change_table :active_storage_attachments do |t|
      t.remove :id, :blob_id, :record_id
      t.rename :uuid, :id
      t.rename :blob_uuid, :blob_id
      t.rename :record_uuid, :record_id
    end
    execute 'ALTER TABLE active_storage_attachments ADD PRIMARY KEY (id);'

    change_table :active_storage_variant_records do |t|
      t.remove :id, :blob_id
      t.rename :uuid, :id
      t.rename :blob_uuid, :blob_id
    end
    execute 'ALTER TABLE active_storage_variant_records ADD PRIMARY KEY (id);'

    # Add foreign key constraints
    add_foreign_key :products, :users, column: :allocated_to_id, primary_key: :id
    add_foreign_key :sales, :products, column: :product_id, primary_key: :id
    add_foreign_key :sales, :users, column: :sold_by_id, primary_key: :id
    add_foreign_key :activity_logs, :users, column: :user_id, primary_key: :id
    add_foreign_key :active_storage_attachments, :active_storage_blobs, column: :blob_id, primary_key: :id
    add_foreign_key :active_storage_variant_records, :active_storage_blobs, column: :blob_id, primary_key: :id
  end

  def down
    raise ActiveRecord::IrreversibleMigration, "Cannot safely revert UUID conversion"
  end
end
