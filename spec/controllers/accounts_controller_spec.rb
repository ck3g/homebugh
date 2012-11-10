require "spec_helper"

describe AccountsController do
  describe "user signed in" do
    login_user
    let(:user) { subject.current_user }
    let(:account) { create :account, user: user }
    let(:cash) { create :account, name: "Cash", user: user }

    it_behaves_like "user is signed in"
    before do
      @user = subject.current_user
    end

    describe "GET #index" do
      before { get :index }
      it { should assign_to(:accounts).with [account] }
      it { should render_template :index }
    end

    describe "GET #new" do
      before { get :new }
      it { should assign_to(:account).with_kind_of Account }
      it { should render_template :new }
    end

    describe "GET #edit" do
      before { get :edit, id: account }
      it { should assign_to(:account).with account }
      it { should render_template :edit }
    end

    describe "POST #create" do
      context "with valid attributes" do
        before { post :create, account: attributes_for(:account) }
        it { should redirect_to accounts_path }
        it "saves the new account in the database" do
          expect {
            post :create, account: attributes_for(:account)
          }.to change(Account, :count).by(1)
        end
      end

      context "with invalid attributes" do
        before { post :create, account: attributes_for(:invalid_account) }
        it { should render_template :new }
        it "does not save the new account in the database" do
          expect {
            post :create, account: attributes_for(:invalid_account)
          }.to_not change(Account, :count).by(1)
        end
      end
    end

    describe "PUT #update" do
      before :each do
        @account = create(:account, name: "Cash-Old", user: @user)
      end

      context "with valid attributes" do
        before { put :update, id: cash, account: attributes_for(:account) }
        it { should assign_to(:account).with cash }
        it { should redirect_to accounts_path }

        it "changes @account's attributes" do
          expect {
            put :update, id: cash, account: attributes_for(:account, name: "Bank Card")
            cash.reload
          }.to change(cash, :name).to("Bank Card")
        end
      end

      context "with invalid attributes" do
        before do
          put :update, id: cash, account: attributes_for(:invalid_account)
        end
        it { should render_template :edit }

        it "does not change the @account's attributes" do
          expect {
            put :update, id: cash, account: attributes_for(:account, name: "")
            cash.reload
          }.to_not change(cash, :name).to("")
        end
      end
    end

    describe "DELETE #destroy" do
      let!(:account) { create :account, user: user }
      let!(:account2) { create :account, user: user }
      before :each do
        @account = create(:account, user: @user)
      end

      context "when account is empty" do
        before { delete :destroy, id: account2 }
        it { should redirect_to accounts_path }
        it "deletes the account" do
          expect {
            delete :destroy, id: account
          }.to change(Account, :count).by(-1)
        end
      end

      context "when account is not empty" do
        let!(:account) { create :account, user: user }
        before do
          account.deposit 100
          delete :destroy, id: account
        end
        it { should redirect_to accounts_path }

        it "does not deletes the account" do
          expect {
            delete :destroy, id: account
          }.to_not change(Account, :count).by(-1)
        end
      end
    end
  end

  describe "user not signed in" do
    let(:account) { create :account }

    describe "GET #index" do
      before { get :index }
      it_behaves_like "has no rights"
    end

    describe "GET #new" do
      before { get :index }
      it_behaves_like "has no rights"
    end

    describe "POST #create" do
      before { post :create, account: attributes_for(:account) }
      it_behaves_like "has no rights"
    end

    describe "GET #edit" do
      before { get :edit, id: account }
      it_behaves_like "has no rights"
    end

    describe "PUT #update" do
      before { put :update, id: account, category: attributes_for(:account) }
      it_behaves_like "has no rights"
    end

    describe "DELETE #destroy" do
      before { delete :destroy, id: account }
      it_behaves_like "has no rights"
    end
  end
end
