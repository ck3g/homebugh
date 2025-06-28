require "rails_helper"

describe AccountsController do
  login_user

  let(:user) { subject.current_user }
  let(:account) { create :account, user: user }
  let(:cash) { create :account, name: "Cash", user: user }

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
    before { get :edit, params: { id: account } }

    it { expect(assigns[:account]).to eq account }
    it { is_expected.to render_template :edit }
  end

  describe "POST #create" do
    let!(:currency) { create :currency }

    context "with valid attributes" do
      def do_request
        post :create, params: { account: attributes_for(:account).merge({ currency_id: currency.id }) }
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
      before { post :create, params: { account: attributes_for(:invalid_account) } }

      it { is_expected.to render_template :new }

      it "does not save the new account in the database" do
        expect {
          post :create, params: { account: attributes_for(:invalid_account) }
        }.to_not change(Account, :count)
      end
    end
  end

  describe "PUT #update" do
    let!(:account) { create(:account, name: "Cash-Old", user: user) }

    context "with valid attributes" do
      before { put :update, params: { id: cash, account: attributes_for(:account) } }

      it { expect(assigns[:account]).to eq cash }
      it { is_expected.to redirect_to accounts_path }

      it "changes @account's attributes" do
        expect {
          put :update, params: { id: cash, account: attributes_for(:account, name: "Bank Card") }
          cash.reload
        }.to change(cash, :name).to("Bank Card")
      end
    end

    context "with invalid attributes" do
      before do
        put :update, params: { id: cash, account: attributes_for(:invalid_account) }
      end
      it { is_expected.to render_template :edit }

      it "does not change the account's attributes" do
        expect {
          put :update, params: { id: cash, account: attributes_for(:account, name: "") }
          cash.reload
        }.to_not change(cash, :name)
      end
    end
  end

  describe "DELETE #destroy" do
    before do
      allow(controller).to receive(:current_user).and_return user
      allow(user).to receive(:accounts).and_return Account
      allow(Account).to receive(:find).and_return account
      allow(account).to receive :destroy

      delete :destroy, params: { id: account }
    end

    it { expect(account).to have_received :destroy }
    it { is_expected.to redirect_to accounts_url }
  end
end
