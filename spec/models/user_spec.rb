require 'rails_helper'

describe User, type: :model do
  it 'has a valid factory' do
    expect(create :user).to be_valid
  end

  describe '.associations' do
    it { is_expected.to have_many(:aggregated_transactions).dependent :destroy }
    it { is_expected.to have_many(:accounts).dependent :destroy }
    it { is_expected.to have_many(:budgets).dependent :destroy }
    it { is_expected.to have_many(:categories).dependent :destroy }
    it { is_expected.to have_many(:transactions).dependent :destroy }
    it { is_expected.to have_many(:cash_flows).dependent :destroy }
  end

  describe '#currencies' do
    subject { user.currencies }

    let(:user) { create(:user) }
    let!(:usd) { create(:currency, name: "USD", unit: "$") }
    let!(:eur) { create(:currency, name: "EUR") }
    let!(:mdl) { create(:currency, name: "MDL") }

    let!(:usd_account) { create(:account, currency: usd, user: user) }
    let!(:usd_account2) { create(:account, currency: usd, user: user) }
    let!(:eur_account) { create(:account, currency: eur, user: user) }
    let!(:mdl_account) { create(:account, currency: mdl) }

    it 'returns unique list of currencies' do
      is_expected.to contain_exactly(usd, eur)
    end
  end
end
