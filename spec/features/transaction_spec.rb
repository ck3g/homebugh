require "spec_helper"

feature "Transaction" do
  given!(:user) { create :user_example_com }
  given!(:account) { create(:account, user: user, name: "Cash") }
  given!(:category) { create(:income_category, user: user, name: "Salary") }
  given!(:transaction) { create(:transaction, user: user, category: category, summ: 100, comment: "My first salary") }

  background do
    sign_in_as 'user@example.com', 'password'
  end

  scenario "should visit transactions page" do
    visit transactions_path
    expect(page).to have_content("List of transactions")
  end

  scenario "visit new transaction page" do
    visit new_transaction_path
    expect(page).to have_content("New transaction")
  end

  scenario "when create transaction" do
    visit new_transaction_path

    select "Cash", from: "transaction_account_id"
    select "Salary", from: "transaction_category_id"
    fill_in "transaction_summ", with: 1000
    fill_in "transaction_comment", with: "My first salary"
    click_button "transaction_submit"

    expect(page).to have_content "Transaction was successfully created."
    expect(page).to have_content "1,000.00"
    expect(page).to have_content "My first salary"
    expect(current_path).to eq transactions_path
  end

  scenario "when rollback transaction" do
    transaction
    visit transactions_path
    click_link "Rollback"

    expect(page).not_to have_content "1,000.00"
    expect(page).not_to have_content "My first salary"
    expect(page).to have_content "You have no transactions."
    expect(current_path).to eq transactions_path
  end
end
