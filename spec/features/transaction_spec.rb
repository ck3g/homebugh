require "rails_helper"

feature "Transaction" do
  given!(:user) { create :user_example_com }
  given!(:currency) { create :currency, name: 'USD', unit: '$' }
  given!(:account) { create :account, user: user, name: "Cash", currency: currency }
  given!(:category) { create :income_category, user: user, name: "Salary" }
  given!(:transaction) { create :transaction, user: user, category: category, summ: 100, comment: "My first salary" }

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

    select "Cash [$]", from: "transaction_account_id"
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
    expect(page).to have_content "Record your first transaction"
    expect(current_path).to eq transactions_path
  end

  scenario "can filter transactions by account" do
    cash_account = create :account, user: user, name: "Cash"
    bank_account = create :account, user: user, name: "Bank"
    cash_transaction = create :transaction, user: user, account: cash_account
    bank_transaction = create :transaction, user: user, account: bank_account

    visit transactions_path

    within "#transaction_#{bank_transaction.id}" do
      click_link "Bank"
    end

    expect(page).to have_selector "#transaction_#{bank_transaction.id}"
    expect(page).not_to have_selector "#transaction_#{cash_transaction.id}"
  end
end
