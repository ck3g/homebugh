require 'rails_helper'

feature 'Create Recurring Payment' do
  given!(:user) { create :user_example_com }
  given!(:currency) { create :currency, name: 'USD', unit: '$' }
  given!(:account) { create :account, user: user, name: "Cash", currency: currency }
  given!(:category) { create :spending_category, user: user, name: "Services" }

  scenario 'a guest cannot visit create recurring payment page' do
    visit '/recurring_payments/new'

    expect(current_path).to eq '/users/sign_in'
    expect(page).to have_content 'You are not authorized to access this page.'
  end

  scenario 'a logged in user can create a recurring payment' do
    sign_in_as 'user@example.com', 'password'

    visit recurring_payments_path
    expect(current_path).to eq recurring_payments_path

    first(:link, 'New recurring payment').click
    expect(current_path).to eq new_recurring_payment_path

    fill_in 'Title', with: 'Some recurring service'
    select 'Cash [$]', from: 'recurring_payment_account_id'
    select 'Services', from: 'recurring_payment_category_id'
    fill_in 'recurring_payment_amount', with: 10
    select_next_payment_date(20.days.from_now.to_date)
    select 'Weekly', from: 'recurring_payment_frequency'
    fill_in 'recurring_payment_frequency_amount', with: 2
    click_button 'recurring_payment_submit'

    expect(current_path).to eq recurring_payments_path
    expect(page).to have_content "The recurring payment was successfully created."
    expect(page).to have_content "Some recurring service"

    rp = user.recurring_payments.last
    expect(rp.title).to eq("Some recurring service")
    expect(rp.account).to eq(account)
    expect(rp.category).to eq(category)
    expect(rp.amount).to eq(10)
    expect(rp.frequency).to eq('weekly')
    expect(rp.frequency_amount).to eq(2)
    expect(rp.next_payment_on).to eq(20.days.from_now.to_date)
  end
end

def select_next_payment_date(date)
  select date.day, from: 'recurring_payment_next_payment_on_3i'
  select date.strftime("%B"), from: 'recurring_payment_next_payment_on_2i'
  select date.year, from: 'recurring_payment_next_payment_on_1i'
end
