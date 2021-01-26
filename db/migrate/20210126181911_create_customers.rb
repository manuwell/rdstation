class CreateCustomers < ActiveRecord::Migration[6.1]
  def change
    create_table :customers do |t|
      t.uuid :uuid, null: false, unique: true
      t.string :name, null: false
      t.integer :score, null: false, default: 0

      t.timestamps
    end
  end
end
