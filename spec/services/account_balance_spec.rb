require 'rails_helper'

RSpec.describe AccountBalance do
  let(:user) { create(:user) }
  let(:spending_category) { create(:spending_category, user: user) }
  let(:income_category) { create(:income_category, user: user) }
  let(:account) { create(:account, user: user, funds: 100) }

  describe '.apply' do
    context 'with a spending transaction' do
      let(:transaction) do
        build(:transaction, user: user, account: account,
              category: spending_category, summ: 30)
      end

      it 'withdraws the amount from the account' do
        AccountBalance.apply(transaction)
        expect(account.reload.funds).to eq(70)
      end
    end

    context 'with an income transaction' do
      let(:transaction) do
        build(:transaction, user: user, account: account,
              category: income_category, summ: 25)
      end

      it 'deposits the amount to the account' do
        AccountBalance.apply(transaction)
        expect(account.reload.funds).to eq(125)
      end
    end

    context 'with a cash flow (same currency)' do
      let(:destination) { create(:account, user: user, funds: 50) }
      let(:cash_flow) do
        build(:cash_flow, user: user, from_account: account,
              to_account: destination, amount: 40)
      end

      it 'withdraws from source account' do
        AccountBalance.apply(cash_flow)
        expect(account.reload.funds).to eq(60)
      end

      it 'deposits to destination account' do
        AccountBalance.apply(cash_flow)
        expect(destination.reload.funds).to eq(90)
      end
    end

    context 'with a cash flow (currency conversion)' do
      let(:destination) { create(:account, user: user, funds: 0) }
      let(:cash_flow) do
        build(:cash_flow, user: user, from_account: account,
              to_account: destination, amount: 35, initial_amount: 50)
      end

      it 'withdraws initial_amount from source account' do
        AccountBalance.apply(cash_flow)
        expect(account.reload.funds).to eq(50)
      end

      it 'deposits amount to destination account' do
        AccountBalance.apply(cash_flow)
        expect(destination.reload.funds).to eq(35)
      end
    end
  end

  describe '.reverse' do
    context 'with a spending transaction' do
      let(:transaction) do
        build(:transaction, user: user, account: account,
              category: spending_category, summ: 30)
      end

      before { AccountBalance.apply(transaction) }

      it 'refunds the amount back to the account' do
        AccountBalance.reverse(transaction)
        expect(account.reload.funds).to eq(100)
      end
    end

    context 'with an income transaction' do
      let(:transaction) do
        build(:transaction, user: user, account: account,
              category: income_category, summ: 25)
      end

      before { AccountBalance.apply(transaction) }

      it 'removes the amount from the account' do
        AccountBalance.reverse(transaction)
        expect(account.reload.funds).to eq(100)
      end
    end

    context 'with a cash flow (same currency)' do
      let(:destination) { create(:account, user: user, funds: 50) }
      let(:cash_flow) do
        build(:cash_flow, user: user, from_account: account,
              to_account: destination, amount: 40)
      end

      before { AccountBalance.apply(cash_flow) }

      it 'refunds to source account' do
        AccountBalance.reverse(cash_flow)
        expect(account.reload.funds).to eq(100)
      end

      it 'removes from destination account' do
        AccountBalance.reverse(cash_flow)
        expect(destination.reload.funds).to eq(50)
      end
    end

    context 'with a cash flow (currency conversion)' do
      let(:destination) { create(:account, user: user, funds: 0) }
      let(:cash_flow) do
        build(:cash_flow, user: user, from_account: account,
              to_account: destination, amount: 35, initial_amount: 50)
      end

      before { AccountBalance.apply(cash_flow) }

      it 'refunds initial_amount to source account' do
        AccountBalance.reverse(cash_flow)
        expect(account.reload.funds).to eq(100)
      end

      it 'removes amount from destination account' do
        AccountBalance.reverse(cash_flow)
        expect(destination.reload.funds).to eq(0)
      end
    end
  end

  describe 'unknown record type' do
    it 'raises ArgumentError on apply' do
      expect { AccountBalance.apply("not a record") }.to raise_error(ArgumentError, /Unknown record type/)
    end

    it 'raises ArgumentError on reverse' do
      expect { AccountBalance.reverse("not a record") }.to raise_error(ArgumentError, /Unknown record type/)
    end
  end
end
