# frozen_string_literal: true

class CreateCollections < ActiveRecord::Migration[6.0]
  def change
    create_table :collections, id: :uuid do |t|
      t.string :customer_names
      t.string :customer_phone_number
      t.string :customer_id_number
      t.datetime :time_collected
      t.string :item
      t.string :collected_by_name
      t.string :collected_by_id_number
      t.string :verification_code
      t.integer :status
      t.string :receipt
      t.string :item_code
      t.string :collection_notes

      t.timestamps
    end
    add_reference(:collections, :store, type: :uuid, foreign_key: true)
    add_reference(:collections, :sale, type: :uuid, foreign_key: true)
    add_reference(:collections, :user, type: :uuid, foreign_key: true)
  end
end
