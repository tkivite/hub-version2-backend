# frozen_string_literal: true

class AddStoreReferenceToUsers < ActiveRecord::Migration[6.0]
  def change
    add_reference :stores, :creator, type: :uuid, foreign_key: { to_table: :users }
    add_reference :partners, :creator, type: :uuid, foreign_key: { to_table: :users }
    add_reference :partners, :account_manager, type: :uuid, foreign_key: { to_table: :users }
  end
end
