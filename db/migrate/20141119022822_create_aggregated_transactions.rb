class CreateAggregatedTransactions < ActiveRecord::Migration
  def change
    create_table :aggregated_transactions do |t|
      t.references :user, index: true, null: false
      t.references :category, index: true, null: false
      t.references :category_type, index: true, null: false
      t.decimal :amount, null: false, precision: 10, scale: 2
      t.datetime :period_started_at, null: false
      t.datetime :period_ended_at, null: false

      t.timestamps
    end
  end
end
