# frozen_string_literal: true

class CreateRoles < ActiveRecord::Migration[6.0]
  def change
    create_table :roles, id: :uuid do |t|
      t.string :name
      t.integer :role_type
      t.float :rank
      t.uuid :created_by

      t.timestamps
    end
  end
end
