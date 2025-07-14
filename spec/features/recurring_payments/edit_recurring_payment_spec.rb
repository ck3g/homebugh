require 'rails_helper'

feature 'Edit Recurring Payment' do
  given!(:user) { create :user_example_com }
  given!(:usd) { create :currency, name: 'USD', unit: '$' }
  given!(:cash_account) { create :account, user: user, name: "Cash", currency: usd }
  given!(:bank_account) { create :account, user: user, name: "Bank", currency: usd }
  given!(:services) { create :spending_category, user: user, name: "Services" }
  given!(:special_services) { create :spending_category, user: user, name: "Special Services" }
  given!(:rp) do
    create(:recurring_payment, title: 'Some recurring service', user: user, account: cash_account, category: services)
  end

  scenario 'a guest cannot visit edit recurring payment page' do
    visit "/recurring_payments/#{rp.id}/edit"

    expect(current_path).to eq('/users/sign_in')
    expect(page).to have_content 'You are not authorized to access this page.'
  end

  scenario 'a logged in user can create a recurring payment' do
    sign_in_as 'user@example.com', 'password'

    visit recurring_payments_path
    expect(current_path).to eq recurring_payments_path

    within "#recurring_payment_#{rp.id}" do
      find('a.btn-edit').click
    end
    expect(current_path).to eq edit_recurring_payment_path(rp)

    fill_in 'Title', with: 'Updated recurring service'
    select 'Bank [$]', from: 'recurring_payment_account_id'
    select 'Special Services', from: 'recurring_payment_category_id'
    fill_in 'recurring_payment_amount', with: 15
    select_next_payment_date(10.days.from_now.to_date)
    select 'Monthly', from: 'recurring_payment_frequency'
    fill_in 'recurring_payment_frequency_amount', with: 1
    select_ends_on_date(1.month.from_now.to_date)
    click_button 'recurring_payment_submit'

    expect(current_path).to eq recurring_payments_path
    expect(page).to have_content "The recurring payment was successfully updated."
    expect(page).to have_content "Updated recurring service"

    rp.reload
    expect(rp.title).to eq("Updated recurring service")
    expect(rp.account).to eq(bank_account)
    expect(rp.category).to eq(special_services)
    expect(rp.amount).to eq(15)
    expect(rp.frequency).to eq('monthly')
    expect(rp.frequency_amount).to eq(1)
    expect(rp.next_payment_on).to eq(10.days.from_now.to_date)
    expect(rp.ends_on).to eq(1.month.from_now.to_date)
  end
end

def select_next_payment_date(date)
  select date.day, from: 'recurring_payment_next_payment_on_3i'
  select date.strftime("%B"), from: 'recurring_payment_next_payment_on_2i'
  select date.year, from: 'recurring_payment_next_payment_on_1i'
end

def select_ends_on_date(date)
  select date.day, from: 'recurring_payment_ends_on_3i'
  select date.strftime("%B"), from: 'recurring_payment_ends_on_2i'
  select date.year, from: 'recurring_payment_ends_on_1i'
end
