require 'rails_helper'

feature 'Create a transaction from a recurring payment' do
  given!(:user) { create :user_example_com }
  given!(:usd) { create :currency, name: 'USD', unit: '$' }
  given!(:bank_account) { create :account, user: user, name: "Bank", currency: usd }
  given!(:services) { create :spending_category, user: user, name: "Services" }
  given(:initial_payment_on) { Date.current }
  given!(:rp) do
    create(:recurring_payment, :monthly, title: 'Some recurring service', user: user, account: bank_account, category: services, next_payment_on: initial_payment_on)
  end

  scenario 'a user can create a transaction by clicking a button next to the recurring payment' do
    sign_in_as 'user@example.com', 'password'
    visit recurring_payments_path

    within "#recurring_payment_#{rp.id}" do
      find('a.create-transaction').click
    end

    expect(page).to have_current_path(transactions_path)
    expect(page).to have_content(I18n.t('parts.transactions.successfully_created'))

    rp.reload
    expect(rp.next_payment_on).to eq(1.month.since(initial_payment_on))

    transaction = user.transactions.last!
    expect(transaction.summ).to eq(rp.amount)
    expect(transaction.comment).to eq(rp.title)
    expect(transaction.category).to eq(rp.category)
    expect(transaction.account).to eq(rp.account)
    expect(transaction.created_at).to be_today
  end
end
