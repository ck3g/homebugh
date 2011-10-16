require 'spec_helper'

describe Category do
  it "model should have no categories" do
    Category.delete_all
    Category.should have(:no).records
  end

  it "should have two categories" do
    Category.delete_all
    Category.create!(:name => "Food", :category_type_id => CategoryType.spending, :user_id => 1)
    Category.create!(:name => "Job Salary", :category_type_id => CategoryType.income, :user_id => 1)
    Category.should have(2).records
  end

  it "with no parameters should not be created" do
    lambda { Category.create! }.should raise_exception ActiveRecord::RecordInvalid
  end

  it "without type should not be created" do
    lambda { Category.create!(:name => "Foot", :user_id => 1) }.should raise_exception ActiveRecord::RecordInvalid
  end

  it "without user should not be created" do
    lambda { Category.create!(:name => "Food", :category_type_id => CategoryType.spending) }.should raise_exception ActiveRecord::RecordInvalid
  end

  it "return correct name" do
    category = Category.new(:name => "Food", :category_type_id => CategoryType.spending, :user_id => 1)
    category.save
    Category.find(category.id).name.should eql "Food"
  end

  it "should be active category by default" do
    category = Category.new(:name => "Active Category", :category_type_id => CategoryType.spending, :user_id => 1)
    category.save
    Category.find(category.id).inactive?.should == false
  end
end
