require "rails_helper"

describe CategoriesController do
  login_user
  let(:user) { subject.current_user }
  let(:category) { create(:category, user: user) }
  let!(:category_type_income) { create(:category_type_income) }
  let(:salary) { create :income_category, name: "Salary", category_type: category_type_income, user: user }

  describe "GET #index" do
    before { get :index }

    it { expect(assigns[:categories]).to eq [category] }
    it { is_expected.to render_template :index }
  end

  describe "GET #new" do
    before { get :new }

    it { expect(assigns[:category]).to be_kind_of Category }
    it { is_expected.to render_template :new }
  end

  describe "GET #edit" do
    before { get :edit, params: { id: category } }

    it { expect(assigns[:category]).to eq category }
    it { is_expected.to render_template :edit }
  end

  describe "POST #create" do
    context "with valid attributes" do
      subject(:create_category) do
        post :create, params: { category: attributes_for(:income_category, name: "Salary 1", category_type_id: category_type_income.id) }
      end

      it { is_expected.to redirect_to categories_path }

      it "saves the new category in the database" do
        expect {
          create_category
        }.to change(Category, :count).by(1)
      end
    end

    context "with invalid attributes" do
      before { post :create, params: { category: attributes_for(:invalid_category) } }

      it { is_expected.to render_template :new }

      it "does not save the new category in the database" do
        expect {
          post :create, params: { category: attributes_for(:invalid_category) }
        }.to_not change(Category, :count)
      end
    end
  end

  describe "PUT #update" do
    context "valid attributes" do
      before { put :update, params: { id: salary, category: attributes_for(:category) } }

      it { expect(assigns[:category]).to eq salary }
      it { is_expected.to redirect_to categories_path }

      it "changes @category's attributes" do
        expect {
          put :update, params: { id: salary, category: attributes_for(:category, name: "Job Salary") }
          salary.reload
        }.to change(salary, :name).to("Job Salary")
      end
    end

    context "invalid attributes" do
      before do
        put :update, params: { id: salary, category: attributes_for(:invalid_category) }
      end

      it "does not change @category's attributes" do
        expect {
          put :update, params: { id: salary, category: attributes_for(:category, name: "Cash", category_type_id: nil) }
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
        delete :destroy, params: { id: category }
      }.to change(Category, :count).by(-1)
    end

    it "redirects to categories page" do
      delete :destroy, params: { id: salary }
      is_expected.to redirect_to categories_path
    end
  end
end
