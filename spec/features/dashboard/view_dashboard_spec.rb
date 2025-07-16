require 'rails_helper'

feature "View dashboard" do
  given!(:user) { create :user_example_com }
  given!(:currency) { create :currency, name: 'USD', unit: '$' }
  given!(:eur_currency) { create :currency, name: 'EUR', unit: '€' }
  given!(:account) { create :account, user: user, name: "Test Account", currency: currency, funds: 1000 }

  background do
    sign_in_as "user@example.com", "password"
  end

  scenario "user can access dashboard from sidebar" do
    visit root_path
    within ".dashboard-sidebar" do
      click_link "Dashboard"
    end

    expect(current_path).to eq dashboard_path
    expect(page).to have_content "Dashboard"
  end

  scenario "user sees account summary on dashboard" do
    visit dashboard_path
    
    expect(page).to have_content "Account summary"
    expect(page).to have_content "Test Account"
    expect(page).to have_content "1,000.00 $"
  end
  
  scenario "user sees spending chart when EUR currency exists" do
    visit dashboard_path
    
    # Should show spending chart since EUR currency exists
    expect(page).to have_content "Current month spending"
  end

end