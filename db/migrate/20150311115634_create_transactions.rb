class CreateTransactions < ActiveRecord::Migration
  def change
    create_table :transactions do |t|
      t.references :user, index: true
      t.integer :movement_type, default: 0
      t.string :ip_address
      t.string :transaction_type
      t.string :transaction_id
      t.string :payer_id
      t.string :currency
      t.string :status
      t.decimal :fee,           :precision => 8, :scale => 2
      t.integer :amount,        :precision => 10, :scale => 2
      t.string :description
      t.string :token

      t.timestamps null: false
    end
    add_foreign_key :transactions, :users
  end
end
