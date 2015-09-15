class AddBookingInfoToUser < ActiveRecord::Migration
  def change
    add_column :users, :name, :string, limit: 50
    add_column :users, :surname, :string, limit: 50
    add_column :users, :dni, :string, limit: 9
    add_column :users, :phone, :string, limit: 12
    add_column :users, :license, :string, limit: 9
  end
end
