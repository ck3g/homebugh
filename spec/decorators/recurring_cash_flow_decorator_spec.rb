require 'rails_helper'

RSpec.describe RecurringCashFlowDecorator, type: :decorator do
  let(:user) { create(:user) }
  let(:usd) { create(:currency, name: 'USD', unit: '$') }
  let(:eur) { create(:currency, name: 'EUR', unit: '€') }
  let(:from_account) { create(:account, user: user, currency: usd) }
  let(:to_account) { create(:account, user: user, currency: eur) }
  let(:recurring_cash_flow) do
    create(:recurring_cash_flow, user: user, from_account: from_account, to_account: to_account, amount: 100, frequency: :monthly)
  end

  subject { recurring_cash_flow.decorate }

  describe '#frequency' do
    it 'returns the localized frequency' do
      expect(subject.frequency).to eq(I18n.t("parts.recurring_payments.frequencies.monthly"))
    end
  end

  describe '#amount' do
    it 'returns the formatted amount with from_account currency unit' do
      expect(subject.amount).to eq("100.00 $")
    end
  end

  describe '#unit' do
    it 'returns the unit of the given account' do
      expect(subject.unit(from_account)).to eq("$")
      expect(subject.unit(to_account)).to eq("€")
    end
  end
end
