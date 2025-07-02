class CreateCountyProviders < ActiveRecord::Migration[8.0]
  def change
    create_table :county_providers do |t|
      t.references :county, null: false, foreign_key: true
      t.references :provider, null: false, foreign_key: true

      t.timestamps
    end
  end
end
