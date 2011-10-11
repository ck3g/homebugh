require "spec_helper"

describe Account do
  it "should have no records" do
    Account.delete_all
    Account.should have(:no).records
  end

  it "should create an account" do
    Account.delete_all
    Account.create!(:name => "New Account", :user_id => 1)
    Account.should have(1).record
  end

  it "with no parameters should not create Account" do
    lambda { Account.create! }.should raise_exception ActiveRecord::RecordInvalid
  end

  it "without name shouldn't create Account" do
    lambda { Account.create!(:user_id => 1) }.should raise_exception ActiveRecord::RecordInvalid
  end

  it "without user shouldn't create Account" do
    lambda { Account.create!(:name => "New Account") }.should raise_exception ActiveRecord::RecordInvalid
  end

  it "amount of fresh created account should be zero" do
    create_account
    @account.funds.should eql 0.0
  end

  it "amount of account should be increased by 100" do
    create_account
    @account.deposit(100)
    @account.funds.should eql 100.00
  end

  it "amount of account should be decreased by 100" do
    create_account
    @account.withdrawal(100)
    @account.funds.should eql -100.00
  end

  it "should raise argument error if nil passed to deposit" do
    create_account
    lambda { @account.deposit(nil) }.should raise_exception ArgumentError
  end

  it "should raise argument error if nil passed to withdrawal" do
    create_account
    lambda { @account.withdrawal(nil) }.should raise_exception ArgumentError
  end

  private
  def create_account
    @account = Account.new(:name => "New Account", :user_id => 1)
    @account.save!
  end
end