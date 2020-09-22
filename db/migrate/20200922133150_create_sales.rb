class CreateSales < ActiveRecord::Migration[6.0]
  def change
    create_table :sales, id: :uuid do |t|
      t.string :customer_names
      t.string :customer_email
      t.string :customer_phone_number
      t.string :customer_id_number
      t.string :buying_price
      t.string :approved_amount
      t.string :item
      t.string :item_type
      t.string :item_description
      t.string :sales_agent
      t.string :store
      t.string :pick_up_type
      t.string :source_id
      t.string :created_by
      t.string :status, default: 'pending'
      t.string :pick_up_option
      t.string :external_id
      t.datetime :collected_at
      t.float :approved_monthly_installment
      t.float :repayment_period
      t.float :interest_rate
      t.datetime :payment_start_date
      t.string :released_item_id
      t.string :item_code
      t.float :item_topup_amount
      t.string :item_topup_ref
      t.float :customer_limit
      t.string :customer_country

      t.timestamps
    end
  end
end
