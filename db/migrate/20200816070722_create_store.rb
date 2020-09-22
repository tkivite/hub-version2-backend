# frozen_string_literal: true

class CreateStore < ActiveRecord::Migration[6.0]
  def change
    create_table :stores, id: :uuid do |t|
      t.string :name
      t.string :store_key
      t.integer :target
      t.string :location
      t.integer :no_of_employess
      t.float :monthly_revenue
      t.string :city
      t.uuid :core_id
      t.string :country
      t.integer :status
      t.timestamps
    end
    add_reference(:stores, :partner, type: :uuid, foreign_key: true)
  end
end
