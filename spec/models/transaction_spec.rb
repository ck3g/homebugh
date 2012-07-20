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
        spending_transaction.income?.should be_false
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
        income_transaction.income?.should be_true
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

  describe "#update" do
    context "when transaction was spending" do
      before do
        spending_transaction
      end

      context "when summ changed" do
        before do
          spending_transaction.update_attributes({summ: 20})
        end

        it "changes account funds" do
          account.reload
          account.funds.should == 30
        end

        it "update summ" do
          spending_transaction.reload.summ.should == 20
        end
      end

      context "when account changed" do
        before do
          spending_transaction.update_attributes({account: bank_account})
        end

        it "changes the account" do
          spending_transaction.account.should == bank_account
        end

        it "refund money back to previous account" do
          account.reload.funds.should == 50
        end

        it "affect to current account" do
          bank_account.reload.funds.should == 89
        end
      end

      context "when category changed" do
        before do
          spending_transaction.update_attributes({category: income_category})
        end

        it "changes the category" do
          spending_transaction.reload.category.should == income_category
        end

        it "become income transaction" do
          spending_transaction.reload.income?.should be_true
        end

        it "affect on account" do
          account.reload.funds.should == 61
        end
      end
    end

    context "when transaction was income" do
      before do
        income_transaction
      end

      context "when summ changed" do
        before do
          income_transaction.update_attributes({summ: 25})
        end

        it "changes account funds" do
          account.reload
          account.funds.should == 75
        end

        it "update summ" do
          income_transaction.reload.summ.should == 25
        end
      end

      context "when account changed" do
        before do
          income_transaction.update_attributes({account: bank_account})
        end

        it "changes the account" do
          income_transaction.account.should == bank_account
        end

        it "refund money back to previous account" do
          account.reload.funds.should == 50
        end

        it "affect to current account" do
          bank_account.reload.funds.should == 112
        end
      end

      context "when category changed" do
        before do
          income_transaction.update_attributes({category: category})
        end

        it "changes the category" do
          income_transaction.reload.category.should == category
        end

        it "become spending transaction" do
          income_transaction.reload.income?.should be_false
        end

        it "affect on account" do
          account.reload.funds.should == 38
        end
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

end
