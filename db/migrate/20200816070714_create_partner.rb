# frozen_string_literal: true

class CreatePartner < ActiveRecord::Migration[6.0]
  def change
    create_table :partners, id: :uuid do |t|
      t.string :name
      t.integer :year_of_incorporation
      t.text :speciality
      t.integer :no_of_branches
      t.string :payment_terms
      t.integer :credit_duration_in_days
      t.string :core_id
      t.string :location
      t.timestamps

     
   
    end
  end
end
