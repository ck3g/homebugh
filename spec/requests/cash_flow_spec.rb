require "spec_helper"

describe "Cash Flows" do

  before(:each) do
    I18n.locale = :en
    @current_user = Factory.create(:user)
    login @current_user
  end

  it "should get list of cash flows" do
    visit cash_flows_path
    page.should have_content("List of cash flows")
    page.has_button?("Move funds").should
  end

  it "should create flow" do
    create_accounts
    create_flow

    page.should have_content("Funds was successfully moved.")
    page.should have_content("From Account → To Account")
    page.should have_content("15.00")
  end

  it "should visit edit flow form" do
    create_accounts
    create_flow

    click_link "Edit"

    page.should have_content("Edit moving funds")
    page.has_select?("cash_flow_from_account_id", :selected => "From Account").should
    page.has_select?("cash_flow_to_account_id", :selected => "To Account").should
    page.has_field?("cash_flow_amount", :with => "10.0").should
  end

  it "should edit flow" do
    create_accounts
    create_flow

    click_link "Edit"
    select "To Account", :from => "cash_flow_from_account_id"
    select "From Account", :from => "cash_flow_to_account_id"
    fill_in "cash_flow_amount", :with => "25"
    click_button "cash_flow_submit"

    page.should have_content("Funds was successfully moved.")
    page.should have_content("To Account → From Account")
    page.should have_content("25.00")
  end

  it "should destroy flow" do
    create_accounts
    create_flow

    page.should have_content("From Account → To Account")
    page.should have_content("15.00")
    click_link "Destroy"
    page.should_not have_content("From Account → To Account")
    page.should_not have_content("15.00")
  end

  it "should raise validation on create" do
    create_accounts
    visit new_cash_flow_path
    select "From Account", :from => "cash_flow_from_account_id"
    select "From Account", :from => "cash_flow_to_account_id"
    fill_in "cash_flow_amount", :with => "0"

    click_button "cash_flow_submit"
    page.should have_content("You cannot move funds to same account")
    page.should have_content("Cannot be less than 0.01")
  end

  it "should raise validation on update" do
    create_accounts
    create_flow
    visit cash_flows_path
    click_link "Edit"

    select "From Account", :from => "cash_flow_from_account_id"
    select "From Account", :from => "cash_flow_to_account_id"
    fill_in "cash_flow_amount", :with => "0"

    click_button "cash_flow_submit"
    page.should have_content("You cannot move funds to same account")
    page.should have_content("Cannot be less than 0.01")
  end

  private

  def create_flow
    visit new_cash_flow_path
    select "From Account", :from => "cash_flow_from_account_id"
    select "To Account", :from => "cash_flow_to_account_id"
    fill_in "cash_flow_amount", :with => 15
    click_button "cash_flow_submit"
  end

  def create_accounts
    create_account "From Account"
    create_account "To Account"
  end

  def create_account(name)
    visit new_account_path
    fill_in "account_name", :with => name
    click_button "Create Account"
  end

end