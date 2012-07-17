require 'spec_helper'

describe Category do

  it "has a valid factory" do
    create(:category).should be_valid
  end

  it "invalid without name" do
    build(:category, name: nil).should_not be_valid
  end

  it "invalid without category_type" do
    build(:category, category_type_id: nil).should_not be_valid
  end

  it "invalid without user" do
    build(:category, user_id: nil).should_not be_valid
  end

  it "is invalid with a duplicate name" do
    user = create(:user)
    create(:category, name: "Food", user: user)
    build(:category, name: "FOOD", user: user).should_not be_valid
  end

  it "allows two users have category with same name" do
    create(:category, name: "Food")
    build(:category, name: "Food").should be_valid
  end

  it "should have two categories" do
    food = create(:category, name: "Food")
    job_salary = create(:category, name: "Job Salary", category_type_id: CategoryType.income)
    Category.all.should == [food, job_salary]
  end

  it "model should have no categories" do
    Category.delete_all
    Category.should have(:no).records
  end

  it "has active category by default" do
    create(:category).inactive?.should be_false
  end
end
