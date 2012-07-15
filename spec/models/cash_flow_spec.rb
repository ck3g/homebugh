require "spec_helper"

describe CashFlow do
  before(:each) do
    @user = FactoryGirl.create(:user)
    @from_account = FactoryGirl.create(:from_account, user: @user)
    @to_account = FactoryGirl.create(:to_account, user: @user)
    @cash_flow = FactoryGirl.create(:cash_flow, user: @user, from_account: @from_account, to_account: @to_account)
  end

  it "should have no records" do
    CashFlow.delete_all
    CashFlow.should have(:no).records
  end

  describe "#move_funds" do
    context "when move funds from one account to another" do
      before do
        @move_result = @cash_flow.move_funds
      end

      it "move_result should be true" do
        @move_result.should be_true
      end

      it "to_account should have 55.0" do
        @to_account.reload.funds.should eql 55.0
      end

      it "from_account should have 45.0" do
        @from_account.reload.funds.should eql 45.0
      end
    end
  end

  it "should refund money back on extended destroy" do
    @cash_flow.move_funds

    @to_account.reload.funds.should eql 55.0
    @from_account.reload.funds.should eql 45.0

    destroy_result = CashFlow.last.extended_destroy

    destroy_result.should eql true
    @to_account.reload.funds.should eql 0.0
    @from_account.reload.funds.should eql 100.0
  end

  it "should refund money back on extended update" do
    @cash_flow.move_funds

    @to_account.reload.funds.should eql 55.0
    @from_account.reload.funds.should eql 45.0

    params = { :from_account_id => @from_account.id, :to_account_id => @to_account.id, user: @user, :amount => 35 }
    update_result = CashFlow.last.extended_update_attributes(params)

    update_result.should eql true
    @to_account.reload.funds.should eql 35.0
    @from_account.reload.funds.should eql 65.0
  end

  it "should not save if amount less than 0.01" do
    cash_flow = CashFlow.new(:from_account => @from_account, :to_account => @to_account, user: @user, :amount => 0)
    cash_flow.move_funds.should_not
  end

  it "should not move to same account" do
    cash_flow = CashFlow.new(:from_account => @from_account, :to_account => @from_account, user: @user, :amount => 1)
    cash_flow.move_funds.should_not
  end
end
