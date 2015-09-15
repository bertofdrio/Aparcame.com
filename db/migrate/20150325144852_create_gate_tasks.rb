class CreateGateTasks < ActiveRecord::Migration
  def change
    create_table :gate_tasks do |t|
      t.references :booking_time, index: true
      t.string :user_phone,   :limit => 12
      t.string :garage_phone, :limit => 12
      t.datetime :time
      t.integer :action, default: 0
      t.datetime :sent_at

      t.timestamps null: false
    end
    add_foreign_key :gate_tasks, :booking_times
  end
end
