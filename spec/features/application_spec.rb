require "spec_helper"

feature "Application" do
  background do
    @current_user = FactoryGirl.create(:user)
    login @current_user
  end

  scenario "should display main menu" do
    visit root_path

    expect(page).to have_selector 'a', text: "Transactions"
    expect(page).to have_selector 'a', text: "Categories"
    expect(page).to have_selector 'a', text: "Accounts"
    expect(page).to have_selector 'a', text: "Cash Flows"
    expect(page).to have_selector 'a', text: "Statistics"
    expect(page).to have_selector 'a', text: "Sign out"
  end
end
