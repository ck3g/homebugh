require "spec_helper"

describe CashFlow do
  let(:user) { create(:user) }
  let(:from_account) { create(:from_account, user: user) }
  let(:to_account) { create(:to_account, user: user) }
  let(:account) { create(:account, user: user, funds: 150) }
  let(:cash_flow) { create(:cash_flow, user: user, from_account: from_account, to_account: to_account) }

  it "should have valid factory" do
    expect(create(:cash_flow)).to be_valid
  end

  describe ".association" do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :from_account }
    it { is_expected.to belong_to :to_account }
  end

  describe ".validation" do
    context "valid" do
      subject { create(:cash_flow) }
      it { is_expected.to validate_presence_of(:amount) }
      it { is_expected.to validate_presence_of(:user_id) }
      it { is_expected.to validate_presence_of(:from_account_id) }
      it { is_expected.to validate_presence_of(:to_account_id) }
      it { is_expected.to allow_value(1).for(:amount) }
    end

    context "invalid" do
      subject { create(:cash_flow) }
      it { is_expected.not_to allow_value(nil).for(:amount) }
      it { is_expected.not_to allow_value(0).for(:amount) }
      it { is_expected.not_to allow_value(nil).for(:user_id) }
      it { is_expected.not_to allow_value(nil).for(:from_account_id) }
      it { is_expected.not_to allow_value(nil).for(:to_account_id) }
    end
  end

  it "should not save if amount less than 0.01" do
    cash_flow = build(:cash_flow, amount: 0)
    expect(cash_flow).not_to be_valid
  end

  it "should not move to same account" do
    cash_flow = build(:cash_flow, from_account: from_account, to_account: from_account)
    expect(cash_flow).not_to be_valid
  end

  describe "#create" do
    before do
      cash_flow
    end

    it "withdraw from from_account" do
      expect(from_account.reload.funds).to eq(45)
    end

    it "deposit to to_account" do
      expect(to_account.reload.funds).to eq(55)
    end
  end

  describe "#destroy" do
    before do
      cash_flow
      cash_flow.destroy
    end

    it "refund money back to from_account" do
      from_account.reload
      expect(from_account.funds).to eq(100)
    end

    it "take money from to_account" do
      to_account.reload
      expect(to_account.funds).to eq(0)
    end
  end
end
