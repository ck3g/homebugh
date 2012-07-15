require "spec_helper"

describe Transaction do
  before do
    @user = FactoryGirl.create(:user)
    @category = FactoryGirl.create(:spending_category, name: "Food", user: @user)
    @account = FactoryGirl.create(:account, name: "Cash", funds: 50, user: @user)
  end

  it "should have no records" do
    Transaction.delete_all
    Transaction.should have(:no).records
  end

  it "should create single transaction" do
    Transaction.delete_all
    transaction = Transaction.new(:category_id => @category.id, :account_id => @account.id, :summ => 10.5, :comment => "First transaction", user: @user)
    transaction.extended_save

    Transaction.should have(1).record
    transaction = Transaction.last
    transaction.category_id.should eql @category.id
    transaction.account_id.should eql @account.id
    transaction.summ.should eql 10.5
    transaction.comment.should eql "First transaction"
    Account.find(@account.id).funds.should eql 39.5
  end

  it "should not save if sum less than 0.01" do
    transaction = Transaction.new(:category_id => @category.id, :account_id => @account.id, user: @user, :summ => 0)
    transaction.extended_save.should_not
  end

  it "should raise exception if have no category" do
    transaction = Transaction.new(:account_id => @account.id, user: @user, :summ => 10)
    lambda { transaction.extended_save }.should raise_exception ActiveRecord::RecordNotFound
  end

  it "should raise exception if have no account" do
    transaction = Transaction.new(:category_id => @category.id, user: @user, :summ => 10)
    lambda { transaction.extended_save }.should raise_exception ActiveRecord::RecordNotFound
  end

  it "should raise exception if have no user" do
    transaction = Transaction.new(:account_id => @account.id, :category_id => @category.id, :summ => 10)
    lambda { transaction.extended_save }.should raise_exception ActiveRecord::RecordNotFound
  end

  it "should update transaction and affect on account" do
    transaction = Transaction.new(:category_id => @category.id, :account_id => @account.id, user: @user, :summ => 10)
    transaction.extended_save

    Account.find(@account).funds.should eql 40.0
    params = { :category_id => @category.id, :account_id => @account.id, user: @user, :summ => 20 }
    transaction.extended_update_attributes(params)

    Transaction.find(transaction).summ.should eql 20.0
    Account.find(@account).funds.should eql 30.0
  end

  it "should remove transaction and affect on account" do
    Transaction.delete_all
    transaction = Transaction.new(:category_id => @category.id, :account_id => @account.id, user: @user, :summ => 10)
    transaction.extended_save

    Account.find(@account).funds.should eql 40.0
    transaction.extended_destroy

    Transaction.should have(:no).records
    Account.find(@account).funds.should eql 50.0
  end
end
