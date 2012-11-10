require "spec_helper"

describe TransactionsController do
  login_user

  let(:user) { subject.current_user }
  let(:account) { create(:account, user: user) }
  let(:category) { create(:category, user: user) }
  let(:transaction) { create(:transaction, user: user, account: account, category: category) }

  it "have a current_user" do
    user.should_not be_nil
  end

  it "user equals to current_user" do
    user.should == subject.current_user
  end

  describe "GET #index" do
    before { get :index }

    it "populates an array of transactions" do
      assigns(:transactions).should == [transaction]
    end

    it "renders the :index view" do
      response.should render_template :index
    end
  end

  describe "GET #new" do
    before { get :new }

    it "assigns a new transaction to @transaction" do
      assigns(:transaction).should be_a_new(Transaction)
    end

    it "renders the :new template" do
      response.should render_template :new
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
      end

      it "saves the new transaction in the database" do
        expect {
          post :create, transaction: @attributes
        }.to change(Transaction, :count).by(1)
      end

      it "redirects to the transactions page" do
        post :create, transaction: @attributes
        response.should redirect_to transactions_path
      end
    end

    context "with invalid attributes" do
      before do
        @attributes = {
          summ: 0,
          category_id: category.id,
          user_id: user.id
        }
      end

      it "does not save the new transaction in the database" do
        expect {
          post :create, transaction: @attributes
        }.to_not change(Transaction, :count).by(1)
      end

      it "re-renders the :new template" do
        post :create, transaction: @attributes
        response.should render_template :new
      end
    end
  end

  describe "DELETE #destroy" do
    before { transaction }

    it "deletes the transaction" do
      expect {
        delete :destroy, id: transaction
      }.to change(Transaction, :count).by(-1)
    end

    it "redirects to transactions page" do
      delete :destroy, id: transaction
      response.should redirect_to transactions_path
    end
  end
end
