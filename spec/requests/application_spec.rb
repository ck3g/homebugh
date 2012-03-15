require "spec_helper"

describe "Application" do
  before(:each) do
    I18n.locale = :en

    @current_user = FactoryGirl.create(:user)
    login @current_user
  end

  it "should display main menu" do
    visit root_path

    page.should have_content("Transactions")
    page.should have_content("Categories")
    page.should have_content("Accounts")
    page.should have_content("Cash Flows")
    page.should have_content("Statistics")
    page.should have_content("Sign out")
  end
end
