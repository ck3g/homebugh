require 'rails_helper'

shared_examples "has no rights" do
  it { is_expected.to redirect_to new_user_session_path }
  # it { should set_the_flash[:alert].to I18n.t("devise.failure.unauthenticated") }
end

shared_examples "user is signed in" do
  it { expect(user).not_to be_nil }
end
