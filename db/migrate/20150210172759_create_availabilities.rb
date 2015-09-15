class CreateAvailabilities < ActiveRecord::Migration
  def change
    create_table :availabilities do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.references :rent, index: true

      t.timestamps null: false
    end
    add_foreign_key :availabilities, :rents
  end
end
