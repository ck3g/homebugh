require "spec_helper"

feature "Categories" do
  given!(:user) { create :user_example_com }

  background do
    sign_in_as 'user@example.com', 'password'

    CategoryType.create!(:name => 'income')
    CategoryType.create!(:name => 'spending')
  end

  context "GET /categories" do

    scenario "should get list of categories" do
      visit categories_path
      page.should have_content "List of categories"
    end

    scenario "move to create category by pressing button" do
      visit categories_path
      click_link "New category"

      page.should have_content("New category")
      page.has_button?("Create Category").should == true
      page.has_field?("category_name").should == true
      page.has_unchecked_field?("category_inactive").should == true
    end
  end

  context "POST /categories" do
    scenario "create category" do
      create_category

      page.should have_content("Category was successfully created.")
      page.should have_content("Food")
    end

    scenario "move to edit category" do
      create_and_move_to_edit_category

      page.should have_content("Edit category")
      page.has_button?("Update Category").should == true
      find_field("category_name").value.should == 'Food'
    end

    scenario "edit category" do
      create_and_move_to_edit_category

      fill_in "category_name", :with => "New category name"
      select "Income", :from => "category_category_type_id"
      click_button "category_submit"

      page.should have_content("Category was successfully updated.")
      page.should have_content("New category name")
    end

    scenario "destroy category" do
      create_category
      page.should have_content("Food")

      click_link "Destroy"

      page.should_not have_content("Food")
      page.should have_content("You have no categories.")
    end

    private

    def create_category
      visit new_category_path
      fill_in "category_name", :with => "Food"
      select "Spending", :from => "category_category_type_id"
      click_button "category_submit"
    end

    def create_and_move_to_edit_category
      create_category

      visit categories_path
      click_link "Edit"
    end
  end
end
