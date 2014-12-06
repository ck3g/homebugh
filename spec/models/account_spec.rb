require "rails_helper"

describe Account do
  it "has a valid factory" do
    expect(create(:account)).to be_valid
  end

  describe ".associations" do
    it { is_expected.to belong_to :user }
    it { is_expected.to have_many(:cash_flows) }
  end

  describe ".validation" do
    context "valid" do
      subject { create(:account) }
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:user_id) }
      it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id) }
    end
  end

  it "invalid without name" do
    expect(build(:account, name: nil)).not_to be_valid
  end

  it "invalid without user" do
    expect(build(:account, user: nil)).not_to be_valid
  end

  it "is invalid with a duplicate name" do
    user = create(:user)
    create(:account, name: "Account", user: user)
    expect(build(:account, name: "ACCOUNT", user: user)).not_to be_valid
  end

  it "allows two users have account with same name" do
    create(:account, name: "Account")
    expect(build(:account, name: "Account")).to be_valid
  end

  it "has 0.0 funds" do
    expect(create(:account).funds).to eq(0.0)
  end

  describe "change amount" do
    let(:account) { create(:account) }

    it "have an empty account" do
      expect(account.funds).to eq(0)
    end

    it "increased amount by 100" do
      account.deposit 100
      expect(account.funds).to eq(100.0)
    end

    it "increased amount by 100 2" do
      account.deposit 100
      expect(account.reload.funds).to eq(100.0)
    end

    it "decreased amount by 100" do
      account.withdrawal 100
      expect(account.funds).to eq(-100.00)
    end

    it "not increased amount" do
      account.deposit nil
      expect(account.funds).to eq(0.0)
    end

    it "not decreased amount" do
      account.withdrawal nil
      expect(account.funds).to eq(0.0)
    end
  end
end
