require 'rails_helper'

RSpec.describe NewUserCheckList do
  let(:user) { create :user }
  let(:check_list) { described_class.new(user: user) }

  describe "#account_hint_done?" do
    subject { check_list.account_hint_done? }

    context "when user has no accounts yet" do
      it { is_expected.to be_falsey }
    end

    context "when user already has an account" do
      let!(:account) { create :account, user: user }

      it { is_expected.to be_truthy }
    end
  end

  describe "#income_category_hint_done?" do
    subject { check_list.income_category_hint_done? }

    context "when user has no income categories yet" do
      it { is_expected.to be_falsey }
    end

    context "when user already has an income category" do
      let!(:category) { create :income_category, user: user }

      it { is_expected.to be_truthy }
    end
  end

  describe "#spending_category_hint_done?" do
    subject { check_list.spending_category_hint_done? }

    context "when user has no spending categories yet" do
      it { is_expected.to be_falsey }
    end

    context "when user already has an spending category" do
      let!(:category) { create :spending_category, user: user }

      it { is_expected.to be_truthy }
    end
  end

  describe "#transaction_hint_done?" do
    subject { check_list.transaction_hint_done? }

    context "when user has no transactions yet" do
      it { is_expected.to be_falsey }
    end

    context "when user already has a transaction" do
      let!(:transaction) { create :transaction, user: user }

      it { is_expected.to be_truthy }
    end
  end
end
