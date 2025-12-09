class CreateActivityLogs < ActiveRecord::Migration[7.1]
  def change
    create_table :activity_logs do |t|
      t.references :user, null: false, foreign_key: true
      t.string :action_type, null: false
      t.string :entity_type, null: false
      t.bigint :entity_id, null: false
      t.jsonb :old_values
      t.jsonb :new_values
      t.string :ip_address
      t.text :user_agent
      t.timestamps
    end

    add_index :activity_logs, :action_type
    add_index :activity_logs, [ :entity_type, :entity_id ]
    add_index :activity_logs, :created_at
  end
end
