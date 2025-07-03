class AddStatusToReservation < ActiveRecord::Migration[8.0]
  def change
    add_column :reservations, :status, :integer, default: 0
    add_index :reservations, :status
  end
end
