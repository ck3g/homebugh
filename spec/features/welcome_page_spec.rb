require 'rails_helper'

feature "Welcome page" do
  scenario "any guest can visit landing page" do
    visit root_path

    expect(page).to have_content "Home finances. Simply organized."
  end
end
