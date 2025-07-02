class CreatePayments < ActiveRecord::Migration[8.0]
  def change
    create_table :payments do |t|
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.integer :method, null: false
      t.references :customer, null: false, foreign_key: true

      t.timestamps
    end
  end
end
