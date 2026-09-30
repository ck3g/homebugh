require 'rails_helper'

describe DailyTransactionTotals, type: :model do
  let(:user) { create :user }
  let(:usd) { create :currency, name: 'USD' }
  let(:eur) { create :currency, name: 'EUR' }
  let(:account_usd) { create :account, user: user, currency: usd }
  let(:account_eur) { create :account, user: user, currency: eur }
  let(:food) { create :spending_category, user: user }
  let(:salary) { create :income_category, user: user }
  let(:today) { Date.current }
  let(:yesterday) { Date.yesterday }

  def add(summ, category, account, on)
    create :transaction, user: user, summ: summ, category: category, account: account,
      created_at: on.to_time.change(hour: 12)
  end

  describe '#by_day' do
    subject(:by_day) { described_class.new(user.transactions, user.transactions.to_a).by_day }

    it 'returns an empty hash when there are no transactions' do
      expect(by_day).to eq({})
    end

    it 'nets income against expenses per day and currency' do
      add 100, salary, account_usd, today
      add 30, food, account_usd, today
      add 12.5, food, account_eur, today
      add 7, food, account_usd, yesterday

      today_totals = by_day[today].map { |t| [t.currency.name, t.amount.to_f] }
      expect(today_totals).to contain_exactly(['USD', 70.0], ['EUR', -12.5])
      expect(by_day[yesterday].map { |t| [t.currency.name, t.amount.to_f] }).to eq [['USD', -7.0]]
    end

    it 'marks a non-negative total as income' do
      add 100, salary, account_usd, today
      add 30, food, account_eur, today

      totals = by_day[today].index_by { |t| t.currency.name }
      expect(totals['USD']).to be_income
      expect(totals['EUR']).not_to be_income
    end

    it 'sums the whole day even when only part of it is on the page' do
      first = add 10, food, account_usd, today
      add 5, food, account_usd, today

      totals = described_class.new(user.transactions, [first]).by_day
      expect(totals[today].first.amount.to_f).to eq(-15.0)
    end

    it 'respects the filtered scope' do
      add 10, food, account_usd, today
      add 5, food, account_eur, today

      scope = user.transactions.account(account_eur.id)
      totals = described_class.new(scope, scope.to_a).by_day
      expect(totals[today].map { |t| t.currency.name }).to eq ['EUR']
    end
  end
end
