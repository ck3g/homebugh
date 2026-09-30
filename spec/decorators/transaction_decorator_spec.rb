require 'rails_helper'

RSpec.describe TransactionDecorator do
  let(:decorator) { TransactionDecorator.new transaction }

  describe '#amount' do
    subject { decorator.amount }

    let(:account) { double decorate: double(unit: '$') }
    let(:transaction) { mock_model Transaction, account: account, summ: 503 }

    it { is_expected.to eq "503.00 $" }
  end
end

RSpec.describe TransactionDecorator, '#rollback_confirmation' do
  let(:user) { create :user }
  let(:euro) { create :currency, name: 'EUR', unit: '€' }
  let(:account) { create :account, user: user, name: 'Bank', currency: euro, funds: 1000 }

  it 'names the expense and the balance after it is rolled back' do
    category = create :spending_category, user: user, name: 'Groceries'
    transaction = create :transaction, user: user, account: account, category: category, summ: 40

    expect(transaction.decorate.rollback_confirmation)
      .to eq "Roll back −40.00 € for Groceries? Bank will go back to 1,000.00 €."
  end

  it 'names the income and the lower balance after it is rolled back' do
    category = create :income_category, user: user, name: 'Salary'
    transaction = create :transaction, user: user, account: account, category: category, summ: 250

    expect(transaction.decorate.rollback_confirmation)
      .to eq "Roll back 250.00 € for Salary? Bank will go back to 1,000.00 €."
  end
end
