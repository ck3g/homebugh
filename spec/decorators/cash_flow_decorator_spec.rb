require 'rails_helper'

RSpec.describe CashFlowDecorator, type: :decorator do
  let(:user) { create :user }
  let(:euro) { create :currency, name: 'EUR', unit: '€' }
  let(:dollar) { create :currency, name: 'USD', unit: '$' }
  let(:bank) { create :account, user: user, name: 'Bank', currency: euro, funds: 500 }
  let(:savings) { create :account, user: user, name: 'Savings', currency: dollar, funds: 0 }

  describe '#rollback_confirmation' do
    it 'names both balances after the transfer is undone' do
      cash_flow = create :cash_flow, user: user, from_account: bank, to_account: savings, amount: 110, initial_amount: 100

      expect(cash_flow.decorate.rollback_confirmation).to eq(
        "Roll back the transfer of 110.00 $ from Bank to Savings? " \
        "Bank will go back to 500.00 € and Savings to 0.00 $."
      )
    end
  end

  describe '#initial_amount_differs?' do
    it 'is false when the same amount moves within one currency' do
      other = create :account, user: user, currency: euro
      cash_flow = create :cash_flow, user: user, from_account: bank, to_account: other, amount: 50, initial_amount: 50

      expect(cash_flow.decorate.initial_amount_differs?).to be false
    end

    it 'is true when the accounts use different currencies' do
      cash_flow = create :cash_flow, user: user, from_account: bank, to_account: savings, amount: 50, initial_amount: 50

      expect(cash_flow.decorate.initial_amount_differs?).to be true
    end
  end
end
