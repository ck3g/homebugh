require "spec_helper"

describe "Transaction" do
  let(:user) { create(:user) }
  let(:account) { create(:account, user: user, name: "Cash") }
  let(:category) { create(:income_category, user: user, name: "Salary") }
  let(:transaction) { create(:transaction, user: user, category: category, summ: 100, comment: "My first salary") }

  before(:each) do
    I18n.locale = :en

    login user

    account
    category
  end

  it "should visit transactions page" do
    visit transactions_path
    page.should have_content("List of transactions")
  end

  it "visit new transaction page" do
    visit new_transaction_path
    page.should have_content("New transaction")
  end

  describe "create" do
    before do
      visit new_transaction_path
      select "Cash", from: "transaction_account_id"
      select "Salary", from: "transaction_category_id"
      fill_in "transaction_summ", with: 1000
      fill_in "transaction_comment", with: "My first salary"
      click_button "transaction_submit"
    end

    subject { page }
    it { should have_content("Transaction was successfully created.") }
    it { should have_content("1,000.00") }
    it { should have_content("My first salary") }
    it { current_path.should == transactions_path }
  end

  describe "delete (rollback)" do
    before do
      transaction
      visit transactions_path
      click_link "Rollback"
    end

    subject { page }
    it { should_not have_content("1,000.00") }
    it { should_not have_content("My first salary") }
    it { should have_content("You have no transactions.") }
    it { current_path.should == transactions_path }
  end

end
