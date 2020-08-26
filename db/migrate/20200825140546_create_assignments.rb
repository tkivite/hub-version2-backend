# frozen_string_literal: true

class CreateAssignments < ActiveRecord::Migration[6.0]
  def change
    create_table :assignments, id: :uuid do |t|
      t.uuid :assigned_by
      t.timestamps
    end
    add_reference(:assignments, :user, type: :uuid, foreign_key: true)
    add_reference(:assignments, :role, type: :uuid, foreign_key: true)
  end
end
