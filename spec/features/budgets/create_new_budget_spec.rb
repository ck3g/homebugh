require 'rails_helper'

feature "Create new budget" do
  given!(:user) { create :user_example_com }
  given!(:eur_currency) { create :currency, name: "EUR" }
  given!(:account) { create :account, name: "Cash", currency: eur_currency, user: user }
  given!(:category) { create :category, name: "Food", user: user }

  background do
    sign_in_as "user@example.com", "password"
  end

  context "when user has no budgets yet" do
    scenario "user will see empty list" do
      visit budgets_path
      click_link 'Start budget planning'
      within '#new_budget' do
        select "Food", from: :budget_category_id
        fill_in :budget_limit, with: 503
        select "EUR", from: :budget_currency_id
        click_button "Add"
      end

      expect(page).to have_content "Food 0 of 503.00 EUR"
    end
  end
end
