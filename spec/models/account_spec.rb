require "spec_helper"

describe Account do
  it "has a valid factory" do
    FactoryGirl.create(:account).should be_valid
  end

  it "invalid without name" do
    FactoryGirl.build(:account, name: nil).should_not be_valid
  end

  it "invalid without user" do
    FactoryGirl.build(:account, user: nil).should_not be_valid
  end

  it "is invalid with a duplicate name" do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:account, name: "Account", user: user)
    FactoryGirl.build(:account, name: "ACCOUNT", user: user).should_not be_valid
  end

  it "allows two users have account with same name" do
    FactoryGirl.create(:account, name: "Account")
    FactoryGirl.build(:account, name: "Account").should be_valid
  end

  it "has 0.0 funds" do
    FactoryGirl.create(:account).funds.should == 0.0
  end

  describe "change amount" do
    before do
      @account = FactoryGirl.create(:account)
    end

    it "increased amount by 100" do
      @account.deposit 100
      @account.funds.should == 100.0
    end

    it "decreased amount by 100" do
      @account.withdrawal 100
      @account.funds.should == -100.00
    end

    it "not increased amount" do
      @account.deposit nil
      @account.funds.should == 0.0
    end

    it "not decreased amount" do
      @account.withdrawal nil
      @account.funds.should == 0.0
    end
  end
end
