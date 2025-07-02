class CreateReservations < ActiveRecord::Migration[8.0]
  def change
    create_table :reservations do |t|
      t.references :customer, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.decimal :price

      t.timestamps
    end
  end
end
