require "rails_helper"

feature "user registration" do
  scenario "sign up with valid credentials" do
    sign_up_as "email@homebugh.info", "secret"

    expect(page).to have_content "A message with a confirmation link has been sent to your email address"
  end

  scenario "sign up with filled in 'name' input (aka Sign up as a bot)" do
    visit new_user_registration_path
    fill_in 'user_name', with: 'I am a bot'
    fill_in 'user_email', with: 'bot@example.com'
    fill_in 'user_password', with: 'bot-password'
    fill_in 'user_password_confirmation', with: 'bot-password'
    click_button I18n.t(:do_sign_up)

    expect(page).to have_content "We're sorry. The registration is now closed."
  end

  scenario "sign in with valid credentials" do
    create :user_example_com
    sign_in_as 'user@example.com', 'password'

    expect(page).to have_content "Sign out"
    expect(page).to have_content "Signed in successfully."
  end
end
