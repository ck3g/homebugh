require 'rails_helper'

feature 'Perform a transfer from a recurring cash flow' do
  given!(:user) { create :user_example_com }
  given!(:usd) { create :currency, name: 'USD', unit: '$' }
  given!(:bank_account) { create :account, user: user, name: "Bank", currency: usd, funds: 1000 }
  given!(:cash_account) { create :account, user: user, name: "Cash", currency: usd, funds: 0 }
  given(:initial_transfer_on) { Date.current }
  given!(:rcf) do
    create(:recurring_cash_flow, :monthly, user: user, from_account: bank_account, to_account: cash_account, amount: 100, next_transfer_on: initial_transfer_on)
  end

  scenario 'a user can perform a transfer by clicking a button next to the recurring cash flow' do
    sign_in_as 'user@example.com', 'password'
    visit recurring_cash_flows_path

    within "#recurring_cash_flow_#{rcf.id}" do
      find('a[title="Perform transfer"]').click
    end

    expect(page).to have_current_path(cash_flows_path)
    expect(page).to have_content(I18n.t('parts.cash_flows.successfully_created'))

    rcf.reload
    expect(rcf.next_transfer_on).to eq(1.month.since(initial_transfer_on))

    bank_account.reload
    cash_account.reload

    expect(bank_account.funds).to eq(900)
    expect(cash_account.funds).to eq(100)
  end
end
