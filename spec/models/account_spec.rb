require "spec_helper"

describe Account do
  it "has a valid factory" do
    create(:account).should be_valid
  end

  describe ".associations" do
    it { should belong_to :user }
    it { should have_many(:cash_flows) }
  end

  describe ".validation" do
    context "valid" do
      subject { create(:account) }
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:user_id) }
      it { should validate_uniqueness_of(:name).scoped_to(:user_id) }
    end
  end

  it "invalid without name" do
    build(:account, name: nil).should_not be_valid
  end

  it "invalid without user" do
    build(:account, user: nil).should_not be_valid
  end

  it "is invalid with a duplicate name" do
    user = create(:user)
    create(:account, name: "Account", user: user)
    build(:account, name: "ACCOUNT", user: user).should_not be_valid
  end

  it "allows two users have account with same name" do
    create(:account, name: "Account")
    build(:account, name: "Account").should be_valid
  end

  it "has 0.0 funds" do
    create(:account).funds.should == 0.0
  end

  describe "change amount" do
    let(:account) { create(:account) }

    it "have an empty account" do
      account.funds.should == 0
    end

    it "increased amount by 100" do
      account.deposit 100
      account.funds.should == 100.0
    end

    it "increased amount by 100 2" do
      account.deposit 100
      account.reload.funds.should == 100.0
    end

    it "decreased amount by 100" do
      account.withdrawal 100
      account.funds.should == -100.00
    end

    it "not increased amount" do
      account.deposit nil
      account.funds.should == 0.0
    end

    it "not decreased amount" do
      account.withdrawal nil
      account.funds.should == 0.0
    end
  end
end
