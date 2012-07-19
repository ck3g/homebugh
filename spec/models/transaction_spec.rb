require "spec_helper"

describe Transaction do
  before do
    @user = FactoryGirl.create(:user)
    @category = FactoryGirl.create(:spending_category, name: "Food", user: @user)
    @account = FactoryGirl.create(:account, name: "Cash", funds: 50, user: @user)
  end

  it "have a valid factory" do
    create(:transaction).should be_valid
  end

  describe ".association" do
    it { should belong_to :category }
    it { should belong_to :user }
    it { should belong_to :account }
  end

  describe ".validations" do
    context "valid" do
      subject { create(:transaction) }
      it { should validate_presence_of(:summ) }
      it { should validate_numericality_of(:summ) }
      it { should allow_value(0.01).for(:summ) }
    end

    context "invalid" do
      subject { create(:transaction) }
      it { should_not allow_value(nil).for(:summ) }
      it { should_not allow_value(0).for(:summ) }
      it { should_not allow_value("string").for(:summ) }
    end
  end

  it "save transaction to the database" do
    expect {
      create(:transaction)
    }.to change(Transaction, :count).by(1)
  end

  describe "change account's amount" do
    before do
      @account = create(:account, user: @user, funds: 30)
    end

    it "creates and decreases account's amount by 15" do
      transaction = build(:transaction, summ: 15, account: @account, user: @user)
      transaction.extended_save
      @account.reload
      @account.funds.should == 15
    end
  end

  it "is not valid if summ less than 0.01" do
    build(:transaction, summ: 0).should_not be_valid
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
