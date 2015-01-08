require 'rails_helper'

describe ArchiveTransactionsService, type: :model do
  describe '#archive' do
    let(:user) { create :user }
    let(:usd) { create :currency, name: 'USD' }
    let(:eur) { create :currency, name: 'EUR' }
    let(:account_usd) { create :account, user: user, currency: usd }
    let(:account_eur) { create :account, user: user, currency: eur }
    let(:food_category) { create :spending_category, user: user }
    let(:salary_category) { create :income_category, user: user }

    before do
      # Last month transactions
      create :transaction, summ: 10.5, user: user, created_at: 1.month.ago,
        category: food_category, account: account_usd
      create :transaction, summ: 30, user: user, created_at: 1.month.ago,
        category: food_category, account: account_usd
      create :transaction, summ: 100, user: user, created_at: 1.month.ago,
        category: salary_category, account: account_usd

      # Last month transaction with different currency
      create :transaction, summ: 150, user: user, created_at: 1.month.ago,
        category: salary_category, account: account_eur

      # Current month transaction
      create :transaction, user: user, category: food_category

      # Different user's transaction
      create :transaction, created_at: 1.month.ago
    end

    subject { ArchiveTransactionsService.new(user, 1.month.ago).archive }

    context 'when no archived data for period' do
      it "archives transactions for previous month" do
        expect { subject }.to change(AggregatedTransaction, :count).by 3
      end

      it "food category has amount of 40.5 USD" do
        subject
        at = user.aggregated_transactions.
          where(category_id: food_category.id, currency_id: usd.id).first
        expect(at.amount.to_f).to eq 40.5
      end

      it "salary category has amount of 100 USD" do
        subject
        at = user.aggregated_transactions.
          where(category_id: salary_category.id, currency_id: usd.id).first
        expect(at.amount.to_f).to eq 100
      end

      it "salary category has amount of 100 EUR" do
        subject
        at = user.aggregated_transactions.
          where(category_id: salary_category.id, currency_id: eur.id).first
        expect(at.amount.to_f).to eq 150
      end
    end

    context 'when archived data already exists' do
      before do
        create :aggregated_transaction, user: user, amount: 99,
          category: salary_category,
          category_type_id: salary_category.category_type_id
        create :aggregated_transaction, user: user, amount: 30,
          category: food_category,
          category_type_id: food_category.category_type_id
      end

      it "food category has amount of 40.5" do
        subject
        at = user.aggregated_transactions.
          where(category_id: food_category.id).first
        expect(at.amount.to_f).to eq 40.5
      end

      it "salary category has amount of 100" do
        subject
        at = user.aggregated_transactions.
          where(category_id: salary_category.id).first
        expect(at.amount.to_f).to eq 100
      end
    end
  end
end
