require 'rails_helper'

feature 'Move recurring payment to the next payment date' do
  given!(:user) { create :user_example_com }
  given!(:usd) { create :currency, name: 'USD', unit: '$' }
  given!(:bank_account) { create :account, user: user, name: "Bank", currency: usd }
  given!(:services) { create :spending_category, user: user, name: "Services" }
  given(:initial_payment_on) { Date.current }
  given!(:rp) do
    create(:recurring_payment, :monthly, title: 'Some recurring service', user: user, account: bank_account, category: services, next_payment_on: initial_payment_on)
  end

  scenario 'a user can move a recurring period to the next payment date' do
    sign_in_as 'user@example.com', 'password'
    visit recurring_payments_path

    within "#recurring_payment_#{rp.id}" do
      find('a.move-to-next-payment').click
    end

    expect(page).to have_current_path(recurring_payments_path)
    rp.reload
    expect(rp.next_payment_on).to eq(1.month.since(initial_payment_on))
  end
end
