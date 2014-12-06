require "spec_helper"

feature "Accounts" do
  given!(:user) { create :user_example_com }

  background do
    sign_in_as 'user@example.com', 'password'
  end

  scenario "should get list of accounts" do
    visit accounts_path
    expect(page).to have_content("List of accounts")
  end

  scenario "should visit create account page by pressing button" do
    visit accounts_path
    click_link "New account"
    expect(page).to have_content("New account")
    expect(page.has_button?("Create Account")).to be_truthy
  end

  scenario "create account" do
    create_account
    expect(page).to have_content("New Account Name")
    expect(page).to have_content("Account was successfully created.")
    expect(page).to have_content("0.00")
  end

  scenario "move to edit account page" do
    create_and_move_to_edit_account
    expect(page).to have_content("Edit account")
    expect(page.has_button?("Update Account")).to be_truthy
    expect(page.has_field?("account_name", :with => "New Account Name")).to be_truthy
  end

  scenario "edit account name" do
    create_and_move_to_edit_account
    fill_in 'account_name', :with => 'New Account Name'
    click_button "account_submit"
    expect(page).to have_content("Account was successfully updated.")
    expect(page).to have_content("New Account Name")
  end

  scenario "remove account if it is empty" do
    create_account
    visit accounts_path
    expect(page).to have_content("New Account Name")
    expect(page).to have_content("0.00")
    click_link "Destroy"

    expect(page).not_to have_content("New Account Name")
    expect(page).to have_content("You have no accounts.")
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
