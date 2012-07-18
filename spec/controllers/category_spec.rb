require "spec_helper"

describe CategoriesController do
  login_user
  before do
    @user = subject.current_user
  end

  it "should have a current_user" do
    @user.should_not be_nil
  end

  describe "GET #index" do
    it "populates an array of categories" do
      category = create(:category, user: @user)
      get :index
      assigns(:categories).should == [category]
    end

    it "renders the :index view" do
      get :index
      response.should render_template :index
    end
  end

  describe "GET #new" do
    it "assigns a new category to @category" do
      get :new
      assigns(:category).should be_a_new(Category)
    end

    it "renders the :new template" do
      get :new
      response.should render_template :new
    end
  end

  describe "GET #edit" do
    it "assigns the requested category to @category" do
      category = create(:category, user: @user)
      get :edit, id: category
      assigns(:category).should == category
    end

    it "renders the :edit template" do
      category = create(:category, user: @user)
      get :edit, id: category
      response.should render_template :edit
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new category in the database" do
        expect {
          post :create, category: attributes_for(:category)
        }.to change(Category, :count).by(1)
      end

      it "redirects to the categories page" do
        post :create, category: attributes_for(:category)
        response.should redirect_to categories_path
      end
    end

    context "with invalid attributes" do
      it "does not save the new category in the database" do
        expect {
          post :create, category: attributes_for(:invalid_category)
        }.to_not change(Category, :count).by(1)
      end

      it "re-renders the :new template" do
        post :create, category: attributes_for(:invalid_category)
        response.should render_template :new
      end
    end
  end

  describe "PUT #update" do
    before :each do
      @category = create(:category, name: "Salary", category_type_id: CategoryType.income, user: @user)
    end

    it "locates the requested category" do
      put :update, id: @category, category: attributes_for(:category)
      assigns(:category).should eq(@category)
    end

    context "valid attributes" do
      it "changes @category's attributes" do
        put :update, id: @category, category: attributes_for(:category, name: "Job Salary")
        @category.reload
        @category.name.should eq("Job Salary")
      end

      it "redirects to the categories page" do
        put :update, id: @category, category: attributes_for(:category)
        response.should redirect_to categories_path
      end
    end

    context "invalid attributes" do
      it "does not change @category's attributes" do
        put :update, id: @category, category: attributes_for(:category, name: "Cash", category_type_id: nil)
        @category.reload
        @category.name.should_not eq("Cash")
      end

      it "re-renders the edit method" do
        put :update, id: @category, category: attributes_for(:invalid_category)
        response.should render_template :edit
      end
    end
  end

  describe "DELETE #destroy" do
    before :each do
      @category = create(:category, user: @user)
    end

    it "deletes the category" do
      expect {
        delete :destroy, id: @category
      }.to change(Category, :count).by(-1)
    end

    it "redirects to categories page" do
      delete :destroy, id: @category
      response.should redirect_to categories_path
    end
  end

end
