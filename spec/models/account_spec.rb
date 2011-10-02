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
    account = Account.new(:name => "New Account", :user_id => 1)
    account.save!
    account.funds.should eql 0.0
  end

  it "amount of account should be increased by 100" do
    Account.create!(:name => "New Account", :user_id => 1)
    account = Account.last
    account.deposit(100)

    account.funds.should eql 100.00
  end

  it "amount of account should be decreased by 100" do
    account = Account.new(:name => "New Account", :user_id => 1)
    account.save!
    account.withdrawal(100)

    account.funds.should eql -100.00
  end


end