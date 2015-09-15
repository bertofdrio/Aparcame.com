class CreateCarparks < ActiveRecord::Migration
  def change
    create_table :carparks do |t|
      t.text :description
      t.integer :number, :limit => 5
      t.decimal :profit, :precision => 10, :scale => 4
      t.decimal :price, :precision => 10, :scale => 4
      t.decimal :reduced_price, :precision => 10, :scale => 4
      t.references :garage
      t.references :user

      t.timestamps null: false
    end
  end
end
