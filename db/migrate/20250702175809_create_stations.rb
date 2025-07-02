class CreateStations < ActiveRecord::Migration[8.0]
  def change
    create_table :stations do |t|
      t.references :county, null: false, foreign_key: true
      t.string :name
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end
  end
end
