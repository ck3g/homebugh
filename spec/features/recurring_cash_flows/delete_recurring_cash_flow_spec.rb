require 'rails_helper'

feature "Delete recurring cash flows" do
  given!(:user) { create(:user_example_com) }
  given!(:rcf1) { create(:recurring_cash_flow, user: user) }
  given!(:rcf2) { create(:recurring_cash_flow, user: user) }

  background do
    sign_in_as 'user@example.com', 'password'
    visit recurring_cash_flows_path
  end

  scenario 'users can delete their own recurring cash flows from the list' do
    visit "/recurring_cash_flows"

    expect(page).to have_content rcf2.amount

    within "#recurring_cash_flow_#{rcf2.id}" do
      find(".btn-delete").click
    end

    expect(current_path).to eq recurring_cash_flows_path
    expect(page).not_to have_selector("#recurring_cash_flow_#{rcf2.id}")
  end
end
