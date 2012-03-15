require "spec_helper"

describe "Accounts" do
  before(:each) do
    I18n.locale = :en

    @current_user = FactoryGirl.create(:user)
    login @current_user
  end

  it "should get list of accounts" do
    visit accounts_path
    page.should have_content("List of accounts")
  end

  it "should visit create account page by pressing button" do
    visit accounts_path
    click_link "New account"
    page.should have_content("New account")
    page.has_button?("Create Account").should == true
  end

  it "create account" do
    create_account
    page.should have_content("New Account Name")
    page.should have_content("Account was successfully created.")
    page.should have_content("0.00")
  end

  it "move to edit account page" do
    create_and_move_to_edit_account
    page.should have_content("Edit account")
    page.has_button?("Update Account").should == true
    page.has_field?("account_name", :with => "New Account Name").should
  end

  it "edit account name" do
    create_and_move_to_edit_account
    fill_in 'account_name', :with => 'New Account Name'
    click_button "account_submit"
    page.should have_content("Account was successfully updated.")
    page.should have_content("New Account Name")
  end

  it "remove account if it is empty" do
    create_account
    visit accounts_path
    page.should have_content("New Account Name")
    page.should have_content("0.00")
    click_link "Destroy"

    page.should_not have_content("New Account Name")
    page.should have_content("You have no accounts.")
  end

  private

  def create_account
    visit new_account_path
    fill_in "account_name", :with => "New Account Name"
    click_button "Create Account"
  end

  def create_and_move_to_edit_account
    create_account
    click_link "Edit"
  end
end
