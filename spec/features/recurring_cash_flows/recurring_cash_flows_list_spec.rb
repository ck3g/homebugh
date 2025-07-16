require 'rails_helper'

feature "Recurring Cash Flows list" do
  given!(:user) { create(:user_example_com) }
  given!(:currency) { create :currency, name: 'USD', unit: '$' }
  given!(:account1) { create :account, user: user, name: "Cash", currency: currency }
  given!(:account2) { create :account, user: user, name: "Bank", currency: currency }

  scenario "logged out users redirect to login page" do
    visit recurring_cash_flows_path

    expect(current_path).to eq "/users/sign_in"
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "logged in users can see 'No active recurring cash flows yet.' message when there are no recurring cash flows yet" do
    sign_in_as 'user@example.com', 'password'
    visit recurring_cash_flows_path

    expect(current_path).to eq recurring_cash_flows_path
    expect(page).to have_content "Set up recurring transfers"
  end

  scenario "logged in users can see list of their existing recurring cash flows" do
    rcf1 = create(:recurring_cash_flow, user: user, from_account: account1, to_account: account2, amount: 100)
    rcf2 = create(:recurring_cash_flow, from_account: account1, to_account: account2, amount: 200) # Other user's

    sign_in_as 'user@example.com', 'password'
    visit recurring_cash_flows_path

    expect(current_path).to eq recurring_cash_flows_path
    expect(page).not_to have_content "Set up recurring transfers"

    within "#recurring_cash_flow_#{rcf1.id}" do
      expect(page).to have_content "Cash"
      expect(page).to have_content "Bank"
      expect(page).to have_content "100.00"
    end

    expect(page).not_to have_content "200.00"
  end

  scenario "logged in users can see active and ended recurring cash flows in separate sections" do
    active_rcf = create(:recurring_cash_flow, user: user, from_account: account1, to_account: account2, ends_on: Date.current + 1.day, amount: 100)
    ended_rcf = create(:recurring_cash_flow, user: user, from_account: account1, to_account: account2, ends_on: Date.current - 1.day, amount: 200)

    sign_in_as 'user@example.com', 'password'
    visit recurring_cash_flows_path

    expect(current_path).to eq recurring_cash_flows_path

    within '#active_recurring_cash_flows' do
      expect(page).to have_content active_rcf.amount
      expect(page).not_to have_content ended_rcf.amount
    end

    within '#ended_recurring_cash_flows' do
      expect(page).to have_content ended_rcf.amount
      expect(page).not_to have_content active_rcf.amount
    end
  end

  scenario "logged in users do not see the ended recurring cash flows section if there are no ended cash flows" do
    active_rcf = create(:recurring_cash_flow, user: user, from_account: account1, to_account: account2, ends_on: 1.day.from_now)

    sign_in_as 'user@example.com', 'password'
    visit recurring_cash_flows_path
  end
end
