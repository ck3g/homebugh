require "spec_helper"

describe CashFlow do
  it "should have no records" do
    CashFlow.delete_all
    CashFlow.should have(:no).records
  end

  it "should move from one account to another" do
    create_accounts_and_cash_flow
    move_result = @cash_flow.move_funds

    move_result.should eql true
    CashFlow.should have(1).record
    Account.find(@to_account).funds.should eql 55.0
    Account.find(@from_account).funds.should eql 45.0
  end

  it "should refund money back on extended destroy" do
    create_accounts_and_cash_flow
    @cash_flow.move_funds

    CashFlow.should have(1).record
    Account.find(@to_account).funds.should eql 55.0
    Account.find(@from_account).funds.should eql 45.0

    destroy_result = CashFlow.last.extended_destroy

    destroy_result.should eql true
    CashFlow.should have(:no).records
    Account.find(@to_account).funds.should eql 0.0
    Account.find(@from_account).funds.should eql 100.0
  end

  it "should refund money back on extended update" do
    create_accounts_and_cash_flow
    @cash_flow.move_funds

    CashFlow.should have(1).record
    Account.find(@to_account).funds.should eql 55.0
    Account.find(@from_account).funds.should eql 45.0

    params = { :from_account_id => @from_account.id, :to_account_id => @to_account.id, :user_id => 1, :amount => 35 }
    update_result = CashFlow.last.extended_update_attributes(params)

    update_result.should eql true
    Account.find(@to_account).funds.should eql 35.0
    Account.find(@from_account).funds.should eql 65.0
  end

  it "should not save if amount less than 0.01" do
    create_accounts
    cash_flow = CashFlow.new(:from_account => @from_account, :to_account => @to_account, :user_id => 1, :amount => 0)
    cash_flow.move_funds.should_not
  end

  it "should not move to same account" do
    create_accounts
    cash_flow = CashFlow.new(:from_account => @from_account, :to_account => @from_account, :user_id => 1, :amount => 1)
    cash_flow.move_funds.should_not
  end

  def create_accounts
    @from_account = Account.new(:name => "From Account", :user_id => 1)
    @from_account.save!
    @from_account.deposit(100)

    @to_account = Account.new(:name => "To Account", :user_id => 1)
    @to_account.save!
  end

  def create_accounts_and_cash_flow
    create_accounts
    @cash_flow = CashFlow.new(:from_account => @from_account, :to_account => @to_account, :amount => 55, :user_id => 1)
  end
end