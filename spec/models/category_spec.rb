require 'rails_helper'

describe Category do
  it "has a valid factory" do
    expect(create(:category)).to be_valid
  end

  it "be an income category" do
    category_type = create(:category_type_income)
    expect(create(:category, category_type: category_type).income?).to be_truthy
  end

  it "be an expense category" do
    category_type = create(:category_type_expense)
    expect(create(:category, category_type: category_type).income?).to be_falsey
  end

  describe ".asscociations" do
    it { is_expected.to belong_to(:user) }
    it { is_expected.to belong_to(:category_type) }
    it { is_expected.to have_many(:budgets).dependent :destroy }
    it { is_expected.to have_many(:transactions).dependent :destroy }
    it { is_expected.to have_many(:aggregated_transactions).dependent :destroy }
    it { is_expected.to have_many(:recurring_payments).dependent :destroy }
  end

  describe ".validations" do
    context "valid" do
      subject { create(:category) }
      it { is_expected.to validate_presence_of(:name) }
      it { is_expected.to validate_presence_of(:category_type_id) }
      it { is_expected.to validate_presence_of(:user_id) }
      it { is_expected.to validate_uniqueness_of(:name).scoped_to(:user_id).ignoring_case_sensitivity }
    end

    context "invalid" do
      subject { create(:category) }
      it { is_expected.not_to allow_value(nil).for(:name) }
      it { is_expected.not_to allow_value(nil).for(:category_type_id) }
      it { is_expected.not_to allow_value(nil).for(:user_id)}
    end
  end

  it "invalid without name" do
    expect(build(:category, name: nil)).not_to be_valid
  end

  it "invalid without category_type" do
    expect(build(:category, category_type_id: nil)).not_to be_valid
  end

  it "invalid without user" do
    expect(build(:category, user_id: nil)).not_to be_valid
  end

  it "is invalid with a duplicate name" do
    user = create(:user)
    create(:category, name: "Food", user: user)
    expect(build(:category, name: "FOOD", user: user)).not_to be_valid
  end

  it "allows two users have category with same name" do
    user = create(:user)
    create(:category, name: "Food")
    expect(build(:category, name: "Food", user: user)).to be_valid
  end

  it "has active category by default" do
    expect(create(:category).inactive?).to be_falsey
  end
end
