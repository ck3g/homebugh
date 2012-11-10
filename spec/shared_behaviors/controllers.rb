require 'spec_helper'

shared_examples "has no rights" do
  it { should redirect_to new_user_session_path }
  it { should set_the_flash[:alert].to I18n.t("devise.failure.unauthenticated") }
end

shared_examples "user is signed in" do
  it { user.should_not be_nil }
end
