class AddBalanceToUsers < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.decimal :balance, :precision => 10, :scale => 2, :default => 0
    end
  end

  def self.down
    remove_column :users, :balance
  end
end
