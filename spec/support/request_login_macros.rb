module RequestLoginMacros

  def sign_in_user(email, password)
    visit new_user_session_path
    fill_in "user_email", with: email
    fill_in "user_password", with: password
    click_button "user_submit"
  end

  def sign_up_user(email, password, password_confirmation = nil)
    password_confirmation ||= password
    visit new_user_registration_path
    fill_in 'user_email', with: email
    fill_in 'user_password', with: password
    fill_in 'user_password_confirmation', with: password_confirmation
    click_button 'user_submit'
  end
end
