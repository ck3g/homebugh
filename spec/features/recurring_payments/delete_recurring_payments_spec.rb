require 'rails_helper'

feature "Delete recurring payments" do
  given!(:user) { create(:user_example_com) }
  given!(:rp1) { create(:recurring_payment, title: 'RP Apartment bills', user: user) }
  given!(:rp2) { create(:recurring_payment, title: 'RP Some Subscription Service', user: user) }

  background do
    sign_in_as 'user@example.com', 'password'
  end

  scenario 'users can delete their own recurring payments from the list' do
    visit "/recurring_payments"

    expect(page).to have_content "RP Some Subscription Service"

    within "#recurring_payment_#{rp2.id}" do
      find(".delete").click
    end

    expect(current_path).to eq recurring_payments_path
    expect(page).not_to have_content "RP Some Subscription Service"
  end
end
