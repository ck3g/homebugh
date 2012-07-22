require "spec_helper"

describe CashFlow do
  let(:user) { create(:user) }
  let(:from_account) { create(:from_account, user: user) }
  let(:to_account) { create(:to_account, user: user) }
  let(:account) { create(:account, user: user, funds: 150) }
  let(:cash_flow) { create(:cash_flow, user: user, from_account: from_account, to_account: to_account) }

  it "should have valid factory" do
    create(:cash_flow).should be_valid
  end

  describe ".association" do
    it { should belong_to :user }
    it { should belong_to :from_account }
    it { should belong_to :to_account }
  end

  describe ".validation" do
    context "valid" do
      subject { create(:cash_flow) }
      it { should validate_presence_of(:amount) }
      it { should validate_presence_of(:user_id) }
      it { should validate_presence_of(:from_account_id) }
      it { should validate_presence_of(:to_account_id) }
      it { should allow_value(1).for(:amount) }
    end

    context "invalid" do
      subject { create(:cash_flow) }
      it { should_not allow_value(nil).for(:amount) }
      it { should_not allow_value(0).for(:amount) }
      it { should_not allow_value(nil).for(:user_id) }
      it { should_not allow_value(nil).for(:from_account_id) }
      it { should_not allow_value(nil).for(:to_account_id) }
    end
  end

  it "should not save if amount less than 0.01" do
    cash_flow = build(:cash_flow, amount: 0)
    cash_flow.should_not be_valid
  end

  it "should not move to same account" do
    cash_flow = build(:cash_flow, from_account: from_account, to_account: from_account)
    cash_flow.should_not be_valid
  end

  describe "#create" do
    before do
      cash_flow
    end

    it "withdraw from from_account" do
      from_account.reload.funds.should == 45
    end

    it "deposit to to_account" do
      to_account.reload.funds.should == 55
    end
  end

  describe "#destroy" do
    before do
      cash_flow
      cash_flow.destroy
    end

    it "refund money back to from_account" do
      from_account.reload
      from_account.funds.should == 100
    end

    it "take money from to_account" do
      to_account.reload
      to_account.funds.should == 0
    end
  end
end
