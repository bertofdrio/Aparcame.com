class CreatePhotos < ActiveRecord::Migration
  def change
    create_table :photos do |t|
      t.integer :number
      t.references :garage, index: true

      t.timestamps null: false
    end
    add_foreign_key :photos, :garages
  end
end
