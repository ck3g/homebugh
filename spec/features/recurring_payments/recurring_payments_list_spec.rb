require 'rails_helper'

feature "Recurring Payments list" do
  given!(:user) { create(:user_example_com) }
  given!(:currency) { create :currency, name: 'USD', unit: '$' }
  given!(:account) { create :account, user: user, name: "Cash", currency: currency }
  given!(:category) { create :income_category, user: user, name: "Salary" }

  scenario "logged out users redirect to login page" do
    visit "/recurring_payments"

    expect(current_path).to eq "/users/sign_in"
    expect(page).to have_content "You are not authorized to access this page."
  end

  scenario "logged in users can see 'No recurring payments' message when there are no recurring payments yet" do
    sign_in_as 'user@example.com', 'password'

    visit "/recurring_payments"

    expect(current_path).to eq recurring_payments_path
    expect(page).to have_content "You have no active recurring payments yet."
  end

  scenario "logged in users can see list of their existing recurring payments" do
    rp1 = create(:recurring_payment, title: "User's rent", user: user, category: category, account: account, amount: 500)
    rp2 = create(:recurring_payment, title: "Other's rent")

    sign_in_as 'user@example.com', 'password'

    visit "/recurring_payments"

    expect(current_path).to eq recurring_payments_path
    expect(page).not_to have_content "You have no active recurring payments yet."

    within "#recurring_payment_#{rp1.id}" do
      expect(page).to have_content "User's rent #{rp1.decorate.next_payment_on}"
    end

    expect(page).not_to have_content "Other's rent #{rp2.decorate.next_payment_on}"
  end

  scenario "logged in users can see active and ended recurring payments in separate sections" do
    active_rp = create(:recurring_payment, title: "Active Payment", user: user, category: category, account: account, ends_on: 1.day.from_now)
    ended_rp = create(:recurring_payment, title: "Ended Payment", user: user, category: category, account: account, ends_on: 1.day.ago)

    sign_in_as 'user@example.com', 'password'

    visit "/recurring_payments"

    expect(current_path).to eq recurring_payments_path

    within '#active_recurring_payments' do
      expect(page).to have_content "Active Payment"
      expect(page).not_to have_content "Ended Payment"
    end

    within '#ended_recurring_payments' do
      expect(page).to have_content "Ended Payment"
      expect(page).not_to have_content "Active Payment"
    end
  end

  scenario "logged in users do not see the ended payments section if there are no ended payments" do
    active_rp = create(:recurring_payment, title: "Active Payment", user: user, category: category, account: account, ends_on: 1.day.from_now)

    sign_in_as 'user@example.com', 'password'

    visit "/recurring_payments"

    expect(current_path).to eq recurring_payments_path

    expect(page).to have_content "Active Payment"
    expect(page).not_to have_content "Ended"
    expect(page).not_to have_content "Ended Payment"
  end
end
