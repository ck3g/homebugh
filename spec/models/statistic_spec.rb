require 'rails_helper'

describe Statistic, type: :model do
  describe '.twelve_month_totals' do
    let!(:user) { create(:user) }
    let!(:usd) { create(:currency, name: 'USD', unit: '$') }
    let!(:eur) { create(:currency, name: 'EUR', unit: '€') }
    let!(:salary) { create(:income_category, name: 'Salary') }
    let!(:food) { create(:spending_category, name: 'Food') }
    
    let(:current_month_stats) do
      [{
        income: 1000,
        spending: 600,
        income_categories: [{ name: 'Salary', sum: 1000 }],
        spending_categories: [{ name: 'Food', sum: 600 }]
      }]
    end
    
    let(:past_months_stats) do
      # Create 12 months of data
      (1..12).map do |months_ago|
        income_transactions = double(:income_relation)
        spending_transactions = double(:spending_relation)
        
        allow(income_transactions).to receive(:pluck).with(:amount).and_return([1200])
        allow(spending_transactions).to receive(:pluck).with(:amount).and_return([700])
        
        {
          months_ago.months.ago.beginning_of_month => {
            income: income_transactions,
            spending: spending_transactions
          }
        }
      end
    end
    
    subject do
      Statistic.twelve_month_totals(usd, user, current_month_stats, past_months_stats)
    end
    
    it 'returns a hash with income, spending, and net_balance' do
      expect(subject).to be_a(Hash)
      expect(subject).to have_key(:income)
      expect(subject).to have_key(:spending)
      expect(subject).to have_key(:net_balance)
    end
    
    it 'calculates total income from current month and past 11 months' do
      # Current month: 1000 + 11 past months * 1200 = 1000 + 13200 = 14200
      expect(subject[:income]).to eq(14200)
    end
    
    it 'calculates total spending from current month and past 11 months' do
      # Current month: 600 + 11 past months * 700 = 600 + 7700 = 8300
      expect(subject[:spending]).to eq(8300)
    end
    
    it 'calculates net balance as income minus spending' do
      expect(subject[:net_balance]).to eq(14200 - 8300)
    end
    
    context 'with empty current month stats' do
      let(:current_month_stats) { [] }
      
      it 'handles empty current month data' do
        expect(subject[:income]).to eq(13200) # 11 months * 1200
        expect(subject[:spending]).to eq(7700) # 11 months * 700
        expect(subject[:net_balance]).to eq(13200 - 7700)
      end
    end
    
    context 'with no past months stats' do
      let(:past_months_stats) { [] }
      
      it 'handles empty past months data' do
        expect(subject[:income]).to eq(1000) # Only current month
        expect(subject[:spending]).to eq(600) # Only current month
        expect(subject[:net_balance]).to eq(1000 - 600)
      end
    end
    
    context 'with nil values in current month stats' do
      let(:current_month_stats) do
        [{
          income: nil,
          spending: nil,
          income_categories: [],
          spending_categories: []
        }]
      end
      
      it 'handles nil values gracefully' do
        expect(subject[:income]).to eq(13200) # 11 months * 1200
        expect(subject[:spending]).to eq(7700) # 11 months * 700
        expect(subject[:net_balance]).to eq(13200 - 7700)
      end
    end
    
    context 'with mixed currency data' do
      let(:past_months_stats) do
        # Create mixed data where some months have no transactions
        income_transactions = double(:income_relation)
        spending_transactions = double(:spending_relation)
        empty_income = double(:empty_income_relation)
        empty_spending = double(:empty_spending_relation)
        
        allow(income_transactions).to receive(:pluck).with(:amount).and_return([1200])
        allow(spending_transactions).to receive(:pluck).with(:amount).and_return([700])
        allow(empty_income).to receive(:pluck).with(:amount).and_return([])
        allow(empty_spending).to receive(:pluck).with(:amount).and_return([])
        
        [
          {
            1.month.ago.beginning_of_month => {
              income: income_transactions,
              spending: spending_transactions
            }
          },
          {
            2.months.ago.beginning_of_month => {
              income: empty_income,
              spending: empty_spending
            }
          }
        ]
      end
      
      it 'handles months with no transactions' do
        # Current month: 1000 + 600, Past months: 1200 + 700
        expect(subject[:income]).to eq(1000 + 1200)
        expect(subject[:spending]).to eq(600 + 700)
        expect(subject[:net_balance]).to eq((1000 + 1200) - (600 + 700))
      end
    end
    
    context 'with more than 11 past months' do
      let(:past_months_stats) do
        # Create 24 months of data
        (1..24).map do |months_ago|
          income_transactions = double(:income_relation)
          spending_transactions = double(:spending_relation)
          
          allow(income_transactions).to receive(:pluck).with(:amount).and_return([1000])
          allow(spending_transactions).to receive(:pluck).with(:amount).and_return([500])
          
          {
            months_ago.months.ago.beginning_of_month => {
              income: income_transactions,
              spending: spending_transactions
            }
          }
        end
      end
      
      it 'only uses the first 11 months of past data' do
        # Current month: 1000 + 600, Past 11 months: 11 * (1000 + 500)
        expect(subject[:income]).to eq(1000 + (11 * 1000))
        expect(subject[:spending]).to eq(600 + (11 * 500))
        expect(subject[:net_balance]).to eq((1000 + 11000) - (600 + 5500))
      end
    end
  end
end