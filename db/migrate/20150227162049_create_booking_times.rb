class CreateBookingTimes < ActiveRecord::Migration
  def change
    create_table :booking_times do |t|
      t.datetime :start_time
      t.datetime :end_time
      t.references :booking, index: true

      t.timestamps null: false
    end
    add_foreign_key :booking_times, :bookings
  end
end
