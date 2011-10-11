require "spec_helper"

describe "Transaction" do
  before(:each) do
    I18n.locale = :en

    @current_user = Factory.create :user
    login @current_user

    CategoryType.create!(:name => 'income')
    CategoryType.create!(:name => 'spending')
  end

  it "should visit transactions page" do
    visit transactions_path
    page.should have_content("List of transactions")
  end

  it "visit new transaction page" do
    visit new_transaction_path
    page.should have_content("New transaction")
  end

  it "should create single transaction" do
    create_transaction

    page.should have_content("Transaction was successfully created.")
    page.should have_content("1,000.00")
    page.should have_content("My first salary")
  end

  it "should edit transaction" do
    create_transaction
    visit transactions_path
    click_link "Edit"

    page.should have_content("Edit transaction")
    page.has_field?("transaction_summ", :with => 1000.0).should
    page.has_field?("transaction_comment", :with => "My first salary").should
    page.has_button?("Update Transaction").should

    fill_in "transaction_summ", :with => 1500
    fill_in "transaction_comment", :with => "Edited salary"
    click_button "transaction_submit"

    page.should have_content("Transaction was successfully updated.")
    page.should have_content("1,500.00")
    page.should have_content("Edited salary")
  end

  it "should delete transaction" do
    create_transaction
    visit transactions_path
    click_link "Destroy"

    page.should_not have_content("1,000.00")
    page.should_not have_content("My first salary")
    page.should have_content("You have no transactions.")
  end

  it "should raise validation on create" do
    create_category_and_account
    visit new_transaction_path
    click_button "transaction_submit"
    page.should have_content("Sum Cannot be less than 0.01")
  end

  it "should raise validation on update" do
    create_category_and_account
    visit new_transaction_path
    fill_in "transaction_summ", :with => 0
    click_button "transaction_submit"
    page.should have_content("Sum Cannot be less than 0.01")
  end

  private
  def create_transaction
    create_category_and_account
    visit new_transaction_path
    select "Cash", :from => "transaction_account_id"
    select "Salary", :from => "transaction_category_id"
    fill_in "transaction_summ", :with => 1000
    fill_in "transaction_comment", :with => "My first salary"
    click_button "transaction_submit"
  end

  def create_category_and_account
    create_category
    create_account
  end

  def create_category
    visit new_category_path
    fill_in "category_name", :with => "Salary"
    select "Income", :from => "category_type_id"
    click_button "category_submit"
  end

  def create_account
    visit new_account_path
    fill_in "account_name", :with => "Cash"
    click_button "account_submit"
  end
end