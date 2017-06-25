require 'rails_helper'

feature "View budgets list" do
  given!(:user) { create :user_example_com }

  background do
    sign_in_as "user@example.com", "password"
  end

  context "when user has no budgets yet" do
    scenario "user will see empty list" do
      visit root_path
      within "div.navbar" do
        click_link "Budgets"
      end

      expect(current_path).to eq budgets_path
      expect(page).to have_selector "h2", text: "Budgets"
      expect(page).to have_content "No active budgets"
    end
  end
end
