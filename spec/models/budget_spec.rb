require 'rails_helper'

RSpec.describe Budget, type: :model do
  it "has a valid factory" do
    expect(create :budget).to be_valid
  end

  describe ".associations" do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :category }
    it { is_expected.to belong_to :currency }
  end

  describe ".validations" do
    context "with valid attributes" do
      subject { create :budget }
      it { is_expected.to validate_presence_of :user }
      it { is_expected.to validate_presence_of :category }
      it { is_expected.to validate_presence_of :currency }
      it { is_expected.to validate_presence_of :limit }
      it do
        is_expected.to validate_numericality_of(:limit)
          .is_greater_than(0)
      end
    end
  end

  describe '#expenses' do
    subject { budget.expenses }

    let(:eur_currency) { create :currency, name: "EUR" }
    let(:usd_currency) { create :currency, name: "USD" }
    let(:user) { create :user }
    let(:food) { create :category, user: user, name: "Food" }
    let(:other) { create :category, user: user, name: "Other" }
    let(:budget) { create :budget, user: user, category: food, currency: eur_currency }
    let(:eur_account) { create :account, user: user, currency: eur_currency }
    let(:another_eur_account) { create :account, user: user, currency: eur_currency }
    let(:usd_account) { create :account, user: user, currency: usd_currency }

    let!(:last_month_transaction) do
      create :transaction, summ: 53.42, user: user, category: food,
             account: eur_account, created_at: 33.days.ago
    end
    let!(:this_month_transaction) do
      create :transaction, summ: 12.34, user: user, category: food,
             account: eur_account
    end
    let!(:another_this_month_transaction) do
      create :transaction, summ: 68.12, user: user, category: food,
             account: another_eur_account
    end
    let!(:other_category_transaction) do
      create :transaction, summ: 8.12, user: user, category: other,
             account: eur_account
    end
    let!(:usd_transaction) do
      create :transaction, summ: 12.10, user: user, category: food,
             account: usd_account
    end


    it "returns sum of transactions of the same currency and same category made in the current month" do
      is_expected.to eq BigDecimal(80.46.to_s)
    end

  end
end
