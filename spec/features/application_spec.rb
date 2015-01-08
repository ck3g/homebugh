require "rails_helper"

feature "Application" do
  given!(:user) { create :user_example_com }

  scenario "should display main menu" do
    sign_in_as 'user@example.com', 'password'
    visit root_path

    expect(page).to have_selector 'a', text: "Transactions"
    expect(page).to have_selector 'a', text: "Categories"
    expect(page).to have_selector 'a', text: "Accounts"
    expect(page).to have_selector 'a', text: "Cash Flows"
    expect(page).to have_selector 'a', text: "Statistics"
    expect(page).to have_selector 'a', text: "Sign out"
  end
end
