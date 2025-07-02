class CreateBikes < ActiveRecord::Migration[8.0]
  def change
    create_table :bikes do |t|
      t.references :station, null: false, foreign_key: true
      t.string :brand
      t.decimal :total_kms, precision: 10, scale: 1
      t.decimal :pricing, precision: 10, scale: 2
      t.integer :status

      t.timestamps
    end
  end
end
