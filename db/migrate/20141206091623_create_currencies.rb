class CreateCurrencies < ActiveRecord::Migration
  def change
    create_table :currencies do |t|
      t.string :name, null: false
      t.string :unit

      t.timestamps
    end

    add_index :currencies, :name, unique: true
  end
end
