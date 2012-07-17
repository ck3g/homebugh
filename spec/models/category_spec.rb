require 'spec_helper'

describe Category do

  it "has a valid factory" do
    FactoryGirl.create(:category).should be_valid
  end

  it "invalid without name" do
    FactoryGirl.build(:category, name: nil).should_not be_valid
  end

  it "invalid without category_type" do
    FactoryGirl.build(:category, category_type_id: nil).should_not be_valid
  end

  it "invalid without user" do
    FactoryGirl.build(:category, user_id: nil).should_not be_valid
  end

  it "is invalid with a duplicate name" do
    user = FactoryGirl.create(:user)
    FactoryGirl.create(:category, name: "Food", user: user)
    FactoryGirl.build(:category, name: "FOOD", user: user).should_not be_valid
  end

  it "allows two users have category with same name" do
    FactoryGirl.create(:category, name: "Food")
    FactoryGirl.build(:category, name: "Food").should be_valid
  end

  it "should have two categories" do
    food = FactoryGirl.create(:category, name: "Food")
    job_salary = FactoryGirl.create(:category, name: "Job Salary", category_type_id: CategoryType.income)
    Category.all.should == [food, job_salary]
  end

  it "model should have no categories" do
    Category.delete_all
    Category.should have(:no).records
  end

  it "should be active category by default" do
    FactoryGirl.create(:category).inactive?.should be_false
  end
end
