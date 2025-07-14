require 'rails_helper'

feature 'Create Recurring Cash Flow' do
  given!(:user) { create :user_example_com }
  given!(:currency) { create :currency, name: 'USD', unit: '$' }
  given!(:account1) { create :account, user: user, name: "Cash", currency: currency }
  given!(:account2) { create :account, user: user, name: "Bank", currency: currency }

  scenario 'a guest cannot visit create recurring cash flow page' do
    visit '/recurring_cash_flows/new'

    expect(current_path).to eq '/users/sign_in'
    expect(page).to have_content 'You are not authorized to access this page.'
  end

  scenario 'a logged in user can create a recurring cash flow' do
    sign_in_as 'user@example.com', 'password'
    visit recurring_cash_flows_path
    expect(current_path).to eq recurring_cash_flows_path

    first(:link, 'New recurring cash flow').click
    expect(current_path).to eq new_recurring_cash_flow_path

    select 'Cash', from: 'recurring_cash_flow_from_account_id'
    select 'Bank', from: 'recurring_cash_flow_to_account_id'
    fill_in 'recurring_cash_flow_amount', with: 50
    select 'Monthly', from: 'recurring_cash_flow_frequency'
    fill_in 'recurring_cash_flow_frequency_amount', with: 1
    select_next_transfer_date(1.month.from_now.to_date)
    select_ends_on_date(1.year.from_now.to_date)
    click_button 'recurring_cash_flow_submit'

    expect(current_path).to eq recurring_cash_flows_path
    expect(page).to have_content "The recurring cash flow was successfully created."

    rcf = user.recurring_cash_flows.last
    expect(rcf.from_account).to eq(account1)
    expect(rcf.to_account).to eq(account2)
    expect(rcf.amount).to eq(50)
    expect(rcf.frequency).to eq('monthly')
    expect(rcf.frequency_amount).to eq(1)
    expect(rcf.next_transfer_on).to eq(1.month.from_now.to_date)
    expect(rcf.ends_on).to eq(1.year.from_now.to_date)
  end

  def select_next_transfer_date(date)
    select date.day, from: 'recurring_cash_flow_next_transfer_on_3i'
    select date.strftime("%B"), from: 'recurring_cash_flow_next_transfer_on_2i'
    select date.year, from: 'recurring_cash_flow_next_transfer_on_1i'
  end

  def select_ends_on_date(date)
    select date.day, from: 'recurring_cash_flow_ends_on_3i'
    select date.strftime("%B"), from: 'recurring_cash_flow_ends_on_2i'
    select date.year, from: 'recurring_cash_flow_ends_on_1i'
  end
end
