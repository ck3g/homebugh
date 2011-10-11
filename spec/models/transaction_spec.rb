require "spec_helper"

describe Transaction do
  it "should have no records" do
    Transaction.delete_all
    Transaction.should have(:no).records
  end

  it "should create single transaction" do
    Transaction.delete_all
    create_category_and_account
    transaction = Transaction.new(:category_id => @category.id, :account_id => @account.id, :summ => 10.5, :comment => "First transaction", :user_id => 1)
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
    create_category_and_account
    transaction = Transaction.new(:category_id => @category.id, :account_id => @account.id, :user_id => 1, :summ => 0)
    transaction.extended_save.should_not
  end

  it "should raise exception if have no category" do
    create_category_and_account
    transaction = Transaction.new(:account_id => @account.id, :user_id => 1, :summ => 10)
    lambda { transaction.extended_save }.should raise_exception ActiveRecord::RecordNotFound
  end

  it "should raise exception if have no account" do
    create_category_and_account
    transaction = Transaction.new(:category_id => @category.id, :user_id => 1, :summ => 10)
    lambda { transaction.extended_save }.should raise_exception ActiveRecord::RecordNotFound
  end

  it "should raise exception if have no user" do
    create_category_and_account
    transaction = Transaction.new(:account_id => @account.id, :category_id => @category.id, :summ => 10)
    lambda { transaction.extended_save }.should raise_exception ActiveRecord::RecordNotFound
  end

  it "should update transaction and affect on account" do
    create_category_and_account
    transaction = Transaction.new(:category_id => @category.id, :account_id => @account.id, :user_id => 1, :summ => 10)
    transaction.extended_save

    Account.find(@account).funds.should eql 40.0
    params = { :category_id => @category.id, :account_id => @account.id, :user_id => 1, :summ => 20 }
    transaction.extended_update_attributes(params)

    Transaction.find(transaction).summ.should eql 20.0
    Account.find(@account).funds.should eql 30.0
  end

  it "should remove transaction and affect on account" do
    Transaction.delete_all
    create_category_and_account
    transaction = Transaction.new(:category_id => @category.id, :account_id => @account.id, :user_id => 1, :summ => 10)
    transaction.extended_save

    Account.find(@account).funds.should eql 40.0
    transaction.extended_destroy

    Transaction.should have(:no).records
    Account.find(@account).funds.should eql 50.0
  end

  private
  def create_category_and_account
    create_category
    create_account
  end

  def create_category
    @category = Category.new(:name => "Food", :category_type_id => CategoryType.spending, :user_id => 1)
    @category.save!
  end

  def create_account
    @account = Account.new(:name => "Cash", :funds => 50, :user_id => 1)
    @account.save!
  end
end