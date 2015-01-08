require "rails_helper"

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
      expect(page).to have_content "List of categories"
    end

    scenario "move to create category by pressing button" do
      visit categories_path
      click_link "New category"

      expect(page).to have_content("New category")
      expect(page.has_button?("Create Category")).to eq(true)
      expect(page.has_field?("category_name")).to eq(true)
      expect(page.has_unchecked_field?("category_inactive")).to eq(true)
    end
  end

  context "POST /categories" do
    scenario "create category" do
      create_category

      expect(page).to have_content("Category was successfully created.")
      expect(page).to have_content("Food")
    end

    scenario "move to edit category" do
      create_and_move_to_edit_category

      expect(page).to have_content("Edit category")
      expect(page.has_button?("Update Category")).to eq(true)
      expect(find_field("category_name").value).to eq('Food')
    end

    scenario "edit category" do
      create_and_move_to_edit_category

      fill_in "category_name", :with => "New category name"
      select "Income", :from => "category_category_type_id"
      click_button "category_submit"

      expect(page).to have_content("Category was successfully updated.")
      expect(page).to have_content("New category name")
    end

    scenario "destroy category" do
      create_category
      expect(page).to have_content("Food")

      click_link "Destroy"

      expect(page).not_to have_content("Food")
      expect(page).to have_content("You have no categories.")
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
