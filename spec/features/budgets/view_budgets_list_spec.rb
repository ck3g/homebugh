require 'rails_helper'

feature "View budgets list" do
  given!(:user) { create :user_example_com }

  background do
    sign_in_as "user@example.com", "password"
  end

  context "when user has no budgets yet" do
    scenario "user will see empty state" do
      visit root_path
      within ".dashboard-sidebar" do
        click_link "Budgets"
      end

      expect(current_path).to eq budgets_path
      expect(page).to have_content "No active budgets"
      expect(page).to have_content "Start budget planning"
      expect(page).to have_selector ".budget-empty-state"
    end
  end
end
