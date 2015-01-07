require "rails_helper"

feature "Cash Flows" do
  given!(:user) { create :user_example_com }
  given!(:source) { create :from_account, user: user, name: "From Account" }
  given!(:destination) { create :to_account, user: user, name: "To Account" }

  background { sign_in_as 'user@example.com', 'password' }

  context "when successfull create" do
    scenario "creates a new cash flow" do
      visit new_cash_flow_path
      select "From Account", from: "cash_flow_from_account_id"
      select "To Account", from: "cash_flow_to_account_id"
      fill_in "cash_flow_amount", with: 15
      click_button "cash_flow_submit"

      expect(page).to have_content "Funds was successfully moved."
      expect(page).to have_content "From Account → To Account"
      expect(page).to have_content "15.00"
      expect(current_path).to eq cash_flows_path
    end
  end

  scenario "rollbacks a flow" do
    create :cash_flow, from_account: source, to_account: destination, amount: 15, user: user

    visit cash_flows_path

    expect(page).to have_content("From Account → To Account")
    expect(page).to have_content("15.00")
    click_link "Rollback"
    expect(page).not_to have_content("From Account → To Account")
    expect(page).not_to have_content("15.00")
  end
end
