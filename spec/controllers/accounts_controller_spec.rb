require "spec_helper"

describe AccountsController do
  login_user
  before do
    @user = subject.current_user
  end

  it "have a current_user" do
    @user.should_not be_nil
  end

  describe "GET #index" do
    it "populates an array of accounts" do
      account = create(:account, user: @user)
      get :index
      assigns(:accounts).should == [account]
    end

    it "renders the :index view" do
      get :index
      response.should render_template :index
    end
  end

  describe "GET #new" do
    it "assigns a new account to @account" do
      get :new
      assigns(:account).should be_a_new(Account)
    end

    it "renders the :new template" do
      get :new
      response.should render_template :new
    end
  end

  describe "GET #edit" do
    before do
      @account = create(:account, user: @user)
    end

    it "assigns the requested account to @account" do
      get :edit, id: @account
      assigns(:account).should == @account
    end

    it "renders the :edit template" do
      get :edit, id: @account
      response.should render_template :edit
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new account in the database" do
        expect {
          post :create, account: attributes_for(:account)
        }.to change(Account, :count).by(1)
      end

      it "redirects to the accounts page" do
        post :create, account: attributes_for(:account)
        response.should redirect_to accounts_path
      end
    end

    context "with invalid attributes" do
      it "does not save the new account in the database" do
        expect {
          post :create, account: attributes_for(:invalid_account)
        }.to_not change(Account, :count).by(1)
      end

      it "re-renders the :new template" do
        post :create, account: attributes_for(:invalid_account)
        response.should render_template :new
      end
    end
  end

  describe "PUT #update" do
    before :each do
      @account = create(:account, name: "Cash", user: @user)
    end

    it "locates the requested account" do
      put :update, id: @account, account: attributes_for(:account)
      assigns(:account).should eq(@account)
    end

    context "with valid attributes" do
      it "changes @account's attributes" do
        put :update, id: @account, account: attributes_for(:account, name: "Bank Card")
        @account.reload
        @account.name.should eq("Bank Card")
      end

      it "redirects to accounts page" do
        put :update, id: @account, account: attributes_for(:account)
        response.should redirect_to accounts_path
      end
    end

    context "with invalid attributes" do
      it "does not change the @account's attributes" do
        put :update, id: @account, account: attributes_for(:account, name: "")
        @account.reload
        @account.name.should_not eq("")
      end

      it "re-renders the :edit template" do
        put :update, id: @account, account: attributes_for(:invalid_account)
        response.should render_template :edit
      end
    end
  end

  describe "DELETE #destroy" do
    before :each do
      @account = create(:account, user: @user)
    end

    context "when account is empty" do
      it "deletes the account" do
        expect {
          delete :destroy, id: @account
        }.to change(Account, :count).by(-1)
      end

      it "redirects to accounts page" do
        delete :destroy, id: @account
        response.should redirect_to accounts_path
      end
    end

    context "when account is not empty" do
      before do
        @account.deposit(100)
      end

      it "does not deletes the account" do
        expect {
          delete :destroy, id: @account
        }.to_not change(Account, :count).by(-1)
      end

      it "redirects to accounts page" do
        delete :destroy, id: @account
        response.should redirect_to accounts_path
      end
    end
  end
end
