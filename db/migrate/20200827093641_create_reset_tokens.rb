class CreateResetTokens < ActiveRecord::Migration[6.0]
  def change
    create_table :reset_tokens, id: :uuid do |t|
      t.string :token
      t.integer :verification_code
      t.date :expiration
      t.boolean :used

      t.timestamps
    end
    add_reference(:reset_tokens, :user, type: :uuid, foreign_key: true)
  end
end
