require 'spec_helper'

describe Category do

  it "has a valid factory" do
    create(:category).should be_valid
  end

  it "be an income category" do
    create(:category, category_type_id: CategoryType.income).income?.should be_true
  end

  it "be a spending category" do
    create(:category, category_type_id: CategoryType.spending).income?.should be_false
  end

  describe ".asscociations" do
    it { should belong_to(:user) }
    it { should belong_to(:category_type) }
    it { should have_many(:transactions) }
  end

  describe ".validations" do
    context "valid" do
      subject { create(:category) }
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:category_type_id) }
      it { should validate_presence_of(:user_id) }
      it { should validate_uniqueness_of(:name).scoped_to(:user_id) }
    end

    context "invalid" do
      subject { create(:category) }
      it { should_not allow_value(nil).for(:name) }
      it { should_not allow_value(nil).for(:category_type_id) }
      it { should_not allow_value(nil).for(:user_id)}
    end
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

  it "has active category by default" do
    create(:category).inactive?.should be_false
  end
end
