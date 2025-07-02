class CreateRides < ActiveRecord::Migration[8.0]
  def change
    create_table :rides do |t|
      t.references :customer, null: false, foreign_key: true
      t.references :bike, null: false, foreign_key: true
      t.datetime :start_time
      t.datetime :end_time
      t.datetime :expected_end_time
      t.decimal :price
      t.references :origin_station, null: false, foreign_key: { to_table: :stations }
      t.references :destination_station, null: true, foreign_key: { to_table: :stations }
      t.references :expected_destination_station, null: true, foreign_key: { to_table: :stations }

      t.timestamps
    end
  end
end
