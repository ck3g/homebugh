require "spec_helper"

describe TransactionsController do
  login_user

  let(:user) { subject.current_user }
  let(:account) { create(:account, user: user) }
  let(:category) { create(:category, user: user) }
  let(:transaction) { create(:transaction, user: user) }

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

  describe "GET #edit" do
    before do
      get :edit, id: transaction
    end

    it "assigns the requested transation to @transaction" do
      assigns(:transaction).should == transaction
    end

    it "renders the :edit template" do
      response.should render_template :edit
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new transaction in the database" do
        # expect {
        #   post :create, transaction: attributes_for(:transaction)
        # }.to change(Transaction, :count).by(1)
      end

      it "redirects to the transactions page" do
        # post :create, transaction: attributes_for(:transaction)
        # response.should redirect_to transactions_path
      end
    end

    context "with invalid attributes" do
      it "does not save the new transaction in the database" do
        expect {
          post :create, transaction: attributes_for(:transaction)
        }.to_not change(Transaction, :count).by(1)
      end

      it "re-renders the :new template" do
        post :create, transaction: attributes_for(:transaction)
        response.should render_template :new
      end
    end
  end

  describe "PUT #update" do
    before :each do
      transaction
    end

    it "locates the requested transaction" do
      put :update, id: transaction, transaction: attributes_for(:transaction)
      assigns(:transaction).should == transaction
    end

    context "valid attributes" do
      it "changes @transaction's attributes" do
        put :update, id: transaction, transaction: attributes_for(:transaction, summ: 20)
        transaction.reload
        transaction.summ.should == 20.0
      end

      it "redirects to transactions page" do
        put :update, id: transaction, transaction: attributes_for(:transaction)
        response.should redirect_to transactions_path
      end
    end

    context "invalid attributes" do
      it "does not change @transaction's attributes" do
        put :update, id: transaction, transaction: attributes_for(:transaction, summ: 30, category_id: nil)
        transaction.reload
        transaction.summ.should_not == 30.0
      end

      it "re-renders the edit method" do
        put :update, id: transaction, transaction: attributes_for(:invalid_transaction)
        response.should render_template :edit
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
