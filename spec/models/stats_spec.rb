require 'spec_helper'

describe Stats, type: :model do
  describe '' do
    let!(:salary) { create :income_category, name: 'Salary' }
    let!(:food) { create :spending_category, name: 'Food' }
    let!(:fuel) { create :spending_category, name: 'Fuel' }

    let!(:at11) do
      create :aggregated_transaction, category: salary, amount: 100,
        category_type_id: salary.category_type_id,
        period_started_at: 1.month.ago.beginning_of_month,
        period_ended_at: 1.month.ago.end_of_month
    end
    let!(:at12) do
      create :aggregated_transaction, category: food, amount: 10,
        category_type_id: food.category_type_id,
        period_started_at: 1.month.ago.beginning_of_month,
        period_ended_at: 1.month.ago.end_of_month
    end
    let!(:at13) do
      create :aggregated_transaction, category: fuel, amount: 15,
        category_type_id: fuel.category_type_id,
        period_started_at: 1.month.ago.beginning_of_month,
        period_ended_at: 1.month.ago.end_of_month
    end
    let!(:at21) do
      create :aggregated_transaction, category: salary, amount: 200,
        category_type_id: salary.category_type_id,
        period_started_at: 2.months.ago.beginning_of_month,
        period_ended_at: 2.months.ago.end_of_month
    end
    let!(:at22) do
      create :aggregated_transaction, category: food, amount: 20,
        category_type_id: food.category_type_id,
        period_started_at: 2.months.ago.beginning_of_month,
        period_ended_at: 2.months.ago.end_of_month
    end

    it do
      expect(Stats.new.all.take(2)).to eq([
        {
          1.month.ago.beginning_of_month => {
            income: [at11], spending: [at12, at13]
        }},
        {
          2.month.ago.beginning_of_month => {
            income: [at21], spending: [at22]
        }}
      ])
    end
  end
end
