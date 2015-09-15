class CreateRents < ActiveRecord::Migration
  def change
    create_table :rents do |t|
      t.string :name
      t.references :carpark

      t.timestamps null: false
    end
  end
end
