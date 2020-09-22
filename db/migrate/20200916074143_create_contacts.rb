# frozen_string_literal: true

class CreateContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :contacts, id: :uuid do |t|
      t.string :type
      t.string :title
      t.string :name
      t.string :email
      t.string :mobile
      t.string :extra_details
      t.uuid :record_id
      t.timestamps
    end
  end
end
