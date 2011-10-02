require "spec_helper"

describe "user registration" do
  before(:each) do
    I18n.locale = :en
  end

  it "should allows new users to register with an email address and password" do
    visit new_user_registration_path
    fill_in 'user_email', :with => "registration_test@example.com"
    fill_in 'user_password', :with => "password"
    fill_in 'user_password_confirmation', :with => "password"

    click_button 'user_submit'

    page.should have_content("You have signed up successfully.")
  end

  it "allows users to sign in after they have registered" do
    User.create(:email => "test_user@example.com", :password => "password")

    visit new_user_session_path

    fill_in 'user_email', :with => "test_user@example.com"
    fill_in 'user_password', :with => "password"

    click_button "user_submit"

    page.should have_content("Signed in successfully.")
  end
end