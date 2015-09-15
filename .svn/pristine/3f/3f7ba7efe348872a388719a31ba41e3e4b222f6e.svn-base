class CreateCharges < ActiveRecord::Migration
  def change
    create_table :charges do |t|
      t.references :booking_time, index: true
      t.datetime :paid_at

      t.timestamps null: false
    end
    add_foreign_key :charges, :booking_times
  end
end
