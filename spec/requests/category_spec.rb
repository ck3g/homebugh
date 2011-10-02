require "spec_helper"

describe "Categories" do
  before(:each) do
    I18n.locale = :en

    @current_user = Factory.create(:user)
    login @current_user

    CategoryType.create!(:name => 'income')
    CategoryType.create!(:name => 'spending')
  end

  describe "GET /categories" do

    it "should get list of categories" do
      visit categories_path
      page.should have_content "List of categories"
    end
  end

  describe "POST /categories" do
    it "create category" do
      visit new_category_path
      fill_in "category_name", :with => "Food"

      select "Spending", :from => "category_type_id"

      click_button "category_submit"

      page.should have_content("Category was successfully created.")
      page.should have_content("Food")
    end
  end
end