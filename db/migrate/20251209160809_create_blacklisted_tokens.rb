class CreateBlacklistedTokens < ActiveRecord::Migration[8.1]
  def change
    create_table :blacklisted_tokens do |t|
      t.string :token_digest, null: false
      t.datetime :expires_at, null: false

      t.timestamps
    end

    add_index :blacklisted_tokens, :token_digest, unique: true
    add_index :blacklisted_tokens, :expires_at
  end
end
