# frozen_string_literal: true

class CreateStoreAccounts < ActiveRecord::Migration[6.0]
  def change
    create_table :store_accounts, id: :uuid do |t|
      t.string :type
      t.string :channel
      t.string :account_type
      t.string :institution
      t.string :account_name
      t.string :account_number
      t.string :payer_identity
      t.string :other_details
      t.timestamps
    end
    add_reference(:store_accounts, :store, type: :uuid, foreign_key: true)
  end
end
