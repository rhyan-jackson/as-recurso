class CreateCounties < ActiveRecord::Migration[8.0]
  def change
    create_table :counties do |t|
      t.string :name
      t.decimal :latitude, precision: 10, scale: 6
      t.decimal :longitude, precision: 10, scale: 6

      t.timestamps
    end
  end
end
