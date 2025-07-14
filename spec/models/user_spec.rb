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
    it { is_expected.to have_many(:recurring_payments).dependent :destroy }
    it { is_expected.to have_many(:recurring_cash_flows).dependent :destroy }
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

  describe '#destroy' do
    subject(:destroy_user) { user.destroy }

    MODELS = [Account, AggregatedTransaction, Budget, CashFlow, Category, Transaction, RecurringPayment, RecurringCashFlow]
    FACTORIES = MODELS.map { |m| m.to_s.underscore.to_sym }

    context 'deleting a user deletes all the user data' do
      let!(:user) { create(:user) }
      let(:user_id) { user.id }

      before do
        FACTORIES.each do |factory|
          create(factory, user: user)
        end
      end

      MODELS.each do |model|
        it "deletes #{model}" do
          expect { destroy_user }.to change { model.where(user_id: user_id).count }.to 0
        end
      end
    end
  end
end
