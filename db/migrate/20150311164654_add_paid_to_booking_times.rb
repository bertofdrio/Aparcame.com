class AddPaidToBookingTimes < ActiveRecord::Migration
  def self.up
    change_table :booking_times do |t|
      t.boolean :paid, :default => false
    end
  end

  def self.down
    remove_column :booking_times, :paid
  end
end
