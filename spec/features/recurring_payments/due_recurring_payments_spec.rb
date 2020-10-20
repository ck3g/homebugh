require 'rails_helper'

feature 'Display due recurring payments on transactions page' do
  given!(:user) { create(:user_example_com) }
  given!(:currency) { create :currency, name: 'USD', unit: '$' }
  given!(:account) { create :account, user: user, name: "Cash", currency: currency }
  given!(:services) { create :spending_category, user: user, name: "Services" }
  given!(:rent) { create :spending_category, user: user, name: "Rent" }
  given!(:due_rp) do
    create(:recurring_payment, :due, user: user, account: account, category: services)
  end
  given!(:future_rp) do
    create(:recurring_payment, :due, user: user, account: account, category: rent, next_payment_on: 1.day.from_now.to_date)
  end
  given!(:other_user_due_rp) { create(:recurring_payment, :due) }

  background do
    sign_in_as 'user@example.com', 'password'
    visit transactions_path
  end

  scenario 'user can see only the list of due recurring payments' do
    within "#recurring_payment_#{due_rp.id}" do
      expect(page).to have_content 'Services'
    end

    expect(page).not_to have_selector("#recurring_payment_#{future_rp.id}")
    expect(page).not_to have_selector("#recurring_payment_#{other_user_due_rp.id}")

    within '#due_recurring_payments' do
      expect(page).not_to have_selector("a.delete")
      expect(page).not_to have_selector("thead")
    end
  end

  scenario 'moving a recurring payment to next period redirects back to transactions page' do
    within "#recurring_payment_#{due_rp.id}" do
      find('a.move-to-next-payment').click
    end

    expect(page).to have_current_path(transactions_path)
  end
end
