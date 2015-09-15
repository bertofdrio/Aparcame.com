class CreateBookings < ActiveRecord::Migration
  def change
    create_table :bookings do |t|
      t.string :name,             :limit => 50
      t.string :license,          :limit => 9
      t.string :phone,            :limit => 12
      t.decimal :price,           :precision => 10, :scale => 4
      t.decimal :reduced_price,   :precision => 10, :scale => 4
      t.references :user
      t.references :carpark

      t.timestamps null: false
    end
  end
end
