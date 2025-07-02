class AddMaxCapacityToStations < ActiveRecord::Migration[8.0]
  def change
    add_column :stations, :max_capacity, :integer
  end
end
