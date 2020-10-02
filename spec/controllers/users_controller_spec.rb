require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  login_user

  describe "GET #delete" do
    it "returns http success" do
      get :delete
      expect(response).to have_http_status(:success)
    end
  end

  describe "DELETE #destroy" do
    describe "with correct password" do
      it "redirects to root_path after success" do
        expect {
          delete :destroy, params: { user: { password: 'password' } }
        }.to change { User.count }.from(1).to(0)
      end

      it "redirects to root_path after success" do
        delete :destroy, params: { user: { password: 'password' } }
        expect(response).to redirect_to(root_path)
      end
    end

    describe "with incorrect password" do
      it "returns http success" do
        expect {
          delete :destroy, params: { user: { password: 'wrong_password' } }
        }.to_not change { User.count }
      end

      it "returns http success" do
        delete :destroy, params: { user: { password: 'wrong_password' } }
        expect(response).to have_http_status(:success)
      end
    end
  end
end
