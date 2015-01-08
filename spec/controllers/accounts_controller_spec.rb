require "rails_helper"

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
      it { expect(assigns[:accounts]).to eq [account] }
      it { is_expected.to render_template :index }
    end

    describe "GET #new" do
      before { get :new }
      it { expect(assigns[:account]).to be_kind_of Account }
      it { is_expected.to render_template :new }
    end

    describe "GET #edit" do
      before { get :edit, id: account }
      it { expect(assigns[:account]).to eq account }
      it { is_expected.to render_template :edit }
    end

    describe "POST #create" do
      let!(:currency) { create :currency }
      context "with valid attributes" do
        def do_request
          post :create, account: attributes_for(:account).
            merge({ currency_id: currency.id })
        end
        before { do_request }
        it { is_expected.to redirect_to accounts_path }
        it "saves the new account in the database" do
          expect {
            do_request
          }.to change(Account, :count).by(1)
        end
      end

      context "with invalid attributes" do
        before { post :create, account: attributes_for(:invalid_account) }
        it { is_expected.to render_template :new }
        it "does not save the new account in the database" do
          expect {
            post :create, account: attributes_for(:invalid_account)
          }.to_not change(Account, :count)
        end
      end
    end

    describe "PUT #update" do
      before :each do
        @account = create(:account, name: "Cash-Old", user: @user)
      end

      context "with valid attributes" do
        before { put :update, id: cash, account: attributes_for(:account) }
        it { expect(assigns[:account]).to eq cash }
        it { is_expected.to redirect_to accounts_path }

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
        it { is_expected.to render_template :edit }

        it "does not change the @account's attributes" do
          expect {
            put :update, id: cash, account: attributes_for(:account, name: "")
            cash.reload
          }.to_not change(cash, :name)
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
        it { is_expected.to redirect_to accounts_path }
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
        it { is_expected.to redirect_to accounts_path }

        it "does not deletes the account" do
          expect {
            delete :destroy, id: account
          }.to_not change(Account, :count)
        end
      end
    end
  end

  # TODO: Replace with cancan matchers
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
