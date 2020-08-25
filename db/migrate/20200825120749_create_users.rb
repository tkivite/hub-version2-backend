class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users, id: :uuid do |t|
      t.string :firstname
      t.string :othernames
      t.string :gender
      t.string :email
      t.string :password_digest
      t.string :mobile
      t.uuid :created_by
      t.datetime :last_login_time
      t.boolean :logged_in
      t.integer :status

      t.timestamps
    end
  end
end
