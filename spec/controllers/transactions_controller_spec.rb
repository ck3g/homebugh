require "rails_helper"

describe TransactionsController do
  login_user

  let(:user) { subject.current_user }
  let(:account) { create(:account, user: user) }
  let(:category) { create(:category, user: user) }
  let!(:transaction) { create(:transaction, user: user, account: account, category: category) }

  describe "GET #index" do
    before { get :index }
    it { expect(assigns[:transactions]).to eq [transaction] }
    it { is_expected.to render_template :index }
  end

  describe "GET #new" do
    before { get :new }
    it { expect(assigns[:transaction]).to be_kind_of Transaction }
    it { is_expected.to render_template :new }

    context "when account_id and category_id in session" do
      before do
        session[:account_id] = account.id
        session[:category_id] = category.id
        get :new
      end

      it "assigns correct category" do
        expect(assigns[:transaction].category_id).to eq(category.id)
      end

      it "assigns correct account" do
        expect(assigns[:transaction].account_id).to eq(account.id)
      end
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      before do
        @attributes = {
          summ: 12,
          account_id: account.id,
          category_id: category.id,
          user_id: user.id
        }
        post :create, transaction: @attributes
      end

      it { is_expected.to redirect_to transactions_path }
      it "sets the session[:account_id]" do
        expect(session[:account_id]).to eq(account.id)
      end

      it "sets the session[:category_id]" do
        expect(session[:category_id]).to eq(category.id)
      end

      it "saves the new transaction in the database" do
        expect {
          post :create, transaction: @attributes
        }.to change(Transaction, :count).by(1)
      end
    end

    context "with invalid attributes" do
      before do
        @attributes = {
          summ: 0,
          category_id: category.id,
          user_id: user.id
        }
        post :create, transaction: @attributes
      end

      it { is_expected.to render_template :new }

      it "does not save the new transaction in the database" do
        expect {
          post :create, transaction: @attributes
        }.to_not change(Transaction, :count)
      end
    end
  end

  describe "PUT #update" do
    let!(:transaction) { mock_model Transaction, id: 1 }

    it 'updates transaction comment only' do
      expect(user).to receive(:transactions).and_return Transaction
      expect(Transaction).to receive(:find).with("1").and_return transaction
      expect(transaction).to receive(:update_attributes).with(
        {"comment" => "New comment"}).and_return true

      put :update, id: 1, transaction: { comment: "New comment", summ: "503" }
    end
  end

  describe "DELETE #destroy" do
  let!(:transaction2) { create(:transaction, user: user, account: account, category: category) }
    before { delete :destroy, id: transaction }
    it { is_expected.to redirect_to transactions_path }

    it "deletes the transaction" do
      expect {
        delete :destroy, id: transaction2
      }.to change(Transaction, :count).by(-1)
    end
  end
end
