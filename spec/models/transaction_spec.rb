require "spec_helper"

describe Transaction do
  let(:user) { create(:user) }
  let(:category) { create(:spending_category, name: "Food", user: user) }
  let(:income_category) { create(:income_category, user: user) }
  let(:account) { create(:account, name: "Cash", funds: 50, user: user) }
  let(:bank_account) { create(:account, name: "Bank", funds: 100, user: user) }
  let(:spending_transaction) { create(:transaction, summ: 11, account: account, user: user, category: category) }
  let(:income_transaction) { create(:transaction, summ: 12, account: account, user: user, category: income_category) }

  it "have a valid factory" do
    create(:transaction).should be_valid
  end

  it "have a invalid factory" do
    build(:invalid_transaction).should_not be_valid
  end

  it "have a valid spending transaction factory" do
    spending_transaction.should be_valid
  end

  it "have a valid income transaction factory" do
    income_transaction.should be_valid
  end

  describe ".association" do
    it { should belong_to :category }
    it { should belong_to :user }
    it { should belong_to :account }
  end

  describe ".validations" do
    context "valid" do
      subject { create(:transaction) }
      it { should validate_presence_of(:account_id) }
      it { should validate_presence_of(:category_id) }
      it { should validate_presence_of(:summ) }
      it { should validate_numericality_of(:summ) }
      it { should allow_value(0.01).for(:summ) }
    end

    context "invalid" do
      subject { create(:transaction) }
      it { should_not allow_value(nil).for(:account_id) }
      it { should_not allow_value(nil).for(:category_id) }
      it { should_not allow_value(nil).for(:summ) }
      it { should_not allow_value(0).for(:summ) }
      it { should_not allow_value("string").for(:summ) }
    end
  end

  describe "#create" do
    context "when spend" do
      it "should not be income" do
        spending_transaction
        spending_transaction.income?.should be_falsey
      end

      it "should affect on account balace" do
        spending_transaction
        account.reload
        account.funds.should == 39
      end

      it "should create transaction" do
        expect {
          spending_transaction
        }.to change(Transaction, :count).by(1)
      end
    end

    context "when income" do
      it "should be income" do
        income_transaction
        income_transaction.income?.should be_truthy
      end

      it "should affect on account balance" do
        income_transaction
        account.reload
        account.funds.should == 62
      end

      it "should create transaction" do
        expect {
          income_transaction
        }.to change(Transaction, :count).by(1)
      end
    end
  end

  describe "#destroy" do
    context "when transaction was spending" do
      before do
        spending_transaction
      end

      it "refund cash back to account" do
        spending_transaction.destroy
        account.reload
        account.funds.should == 50
      end

      it "transaction deleted" do
        expect {
          spending_transaction.destroy
        }.to change(Transaction, :count).by(-1)
      end
    end

    context "when transaction was income" do
      before do
        income_transaction
      end

      it "refund cash back to account" do
        income_transaction.destroy
        account.reload
        account.funds.should == 50
      end

      it "transaction deleted" do
        expect {
          income_transaction.destroy
        }.to change(Transaction, :count).by(-1)
      end
    end
  end

  it "save transaction to the database" do
    expect {
      create(:transaction)
    }.to change(Transaction, :count).by(1)
  end

  it "is not valid if summ less than 0.01" do
    build(:transaction, summ: 0).should_not be_valid
  end

  describe ".scopes" do
    describe ".category" do
      before do
        spending_transaction
        income_transaction
      end
      it "returns transactions for same category only" do
        expect(Transaction.category(category.id)).to eq [spending_transaction]
      end
    end
  end

end
