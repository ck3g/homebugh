require "spec_helper"

describe "user registration" do
  before(:each) do
    I18n.locale = :en
  end

  describe "register" do
    before do
      @email = "email@homebugh.info"
      @password = "secret"
    end

    context "when success" do
      before do
        sign_up_user(@email, @password)
      end

      it "signed up" do
        page.should have_content("You have signed up successfully.")
      end
    end
  end

  describe "authenticate" do
    context "when success" do
      before do
        @user = create(:user)
        sign_in_user @user.email, @user.password
      end

      it "have Sign out link" do
        page.should have_content "Sign out"
      end

      it "have Signed in notice" do
        page.should have_content "Signed in successfully."
      end
    end
  end

end
