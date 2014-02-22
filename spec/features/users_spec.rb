require "spec_helper"

feature "user registration" do
  scenario "sign up with valid credentials" do
    sign_up_user "email@homebugh.info", "secret"

    expect(page).to have_content "You have signed up successfully."
  end

  scenario "sign in with valid credentials" do
    user = create(:user)
    sign_in_user user.email, user.password

    expect(page).to have_content "Sign out"
    expect(page).to have_content "Signed in successfully."
  end
end
