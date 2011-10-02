module RequestMacros
  def login(user)
    page.driver.post user_session_path, :user => {:email => user.email, :password => user.password}
  end
end