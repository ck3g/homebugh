require "spec_helper"

describe CategoriesController do

  describe "user is signed in" do
    login_user
    let(:user) { subject.current_user }
    let(:category) { create(:category, user: user) }
    let(:salary) { create :category, name: "Salary", category_type_id: CategoryType.income, user: user }

    it_behaves_like "user is signed in"

    describe "GET #index" do
      before { get :index }
      it { is_expected.to assign_to(:categories).with [category] }
      it { is_expected.to render_template :index }
    end

    describe "GET #new" do
      before { get :new }
      it { is_expected.to assign_to(:category).with_kind_of Category }
      it { is_expected.to render_template :new }
    end

    describe "GET #edit" do
      before { get :edit, id: category }
      it { is_expected.to assign_to(:category).with category }
      it { is_expected.to render_template :edit }
    end

    describe "POST #create" do
      context "with valid attributes" do
        before do
          post :create, category: attributes_for(:category, name: "Salary 1")
        end

        it { is_expected.to redirect_to categories_path }

        it "saves the new category in the database" do
          expect {
            post :create, category: attributes_for(:category, name: "Salary 2")
          }.to change(Category, :count).by(1)
        end
      end

      context "with invalid attributes" do
        before { post :create, category: attributes_for(:invalid_category) }
        it { is_expected.to render_template :new }

        it "does not save the new category in the database" do
          expect {
            post :create, category: attributes_for(:invalid_category)
          }.to_not change(Category, :count)
        end
      end
    end

    describe "PUT #update" do
      context "valid attributes" do
        before { put :update, id: salary, category: attributes_for(:category) }
        it { is_expected.to assign_to(:category).with salary }
        it { is_expected.to redirect_to categories_path }

        it "changes @category's attributes" do
          expect {
            put :update, id: salary, category: attributes_for(:category, name: "Job Salary")
            salary.reload
          }.to change(salary, :name).to("Job Salary")
        end
      end

      context "invalid attributes" do
        before do
          put :update, id: salary, category: attributes_for(:invalid_category)
        end

        it "does not change @category's attributes" do
          expect {
            put :update, id: salary, category: attributes_for(:category, name: "Cash", category_type_id: nil)
            salary.reload
          }.to_not change(salary, :name)
        end

        it { is_expected.to render_template :edit }
      end
    end

    describe "DELETE #destroy" do
      let!(:category) { create :category, user: user }
      let!(:salary) { create :category, user: user, name: "Salary" }
      it "deletes the category" do
        expect {
          delete :destroy, id: category
        }.to change(Category, :count).by(-1)
      end

      it "redirects to categories page" do
        delete :destroy, id: salary
        is_expected.to redirect_to categories_path
      end
    end
  end

  describe "user not signed in" do
    let(:category) { create :category }

    describe "GET #index" do
      before { get :index }
      it_behaves_like "has no rights"
    end

    describe "GET #new" do
      before { get :index }
      it_behaves_like "has no rights"
    end

    describe "POST #create" do
      before { post :create, category: attributes_for(:category) }
      it_behaves_like "has no rights"
    end

    describe "GET #edit" do
      before { get :edit, id: category }
      it_behaves_like "has no rights"
    end

    describe "PUT #update" do
      before { put :update, id: category, category: attributes_for(:category) }
      it_behaves_like "has no rights"
    end

    describe "DELETE #destroy" do
      before { delete :destroy, id: category }
      it_behaves_like "has no rights"
    end
  end
end
