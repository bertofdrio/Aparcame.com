class CreateGarages < ActiveRecord::Migration
  def change
    create_table :garages do |t|
      t.string :name, limit: 50
      t.string :address, limit: 255
      t.string :city, limit: 50
      t.references :province
      t.string :phone,limit: 11
      t.integer :postal_code

      t.timestamps null: false
    end
  end
end
