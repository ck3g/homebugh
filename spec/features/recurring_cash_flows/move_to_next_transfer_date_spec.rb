require 'rails_helper'

feature 'Move recurring cash flow to the next transfer date' do
  given!(:user) { create :user_example_com }
  given!(:usd) { create :currency, name: 'USD', unit: '$' }
  given!(:account1) { create :account, user: user, name: "Cash", currency: usd }
  given!(:account2) { create :account, user: user, name: "Bank", currency: usd }
  given(:initial_transfer_on) { Date.current }
  given!(:rcf) do
    create(:recurring_cash_flow, :monthly, user: user, from_account: account1, to_account: account2, next_transfer_on: initial_transfer_on)
  end

  scenario 'a user can move a recurring cash flow to the next transfer date' do
    sign_in_as 'user@example.com', 'password'
    visit recurring_cash_flows_path

    within "#recurring_cash_flow_#{rcf.id}" do
      find('a.btn-sm[title="Move to next transfer date"]').click
    end

    expect(page).to have_current_path(recurring_cash_flows_path)
    rcf.reload
    expect(rcf.next_transfer_on).to eq(1.month.since(initial_transfer_on))
  end
end
