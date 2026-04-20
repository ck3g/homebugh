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
    it { is_expected.to have_many(:budgets).dependent :restrict_with_error }
    it { is_expected.to have_many(:transactions).dependent :restrict_with_error }
    it { is_expected.to have_many(:aggregated_transactions).dependent :restrict_with_error }
    it { is_expected.to have_many(:recurring_payments).dependent :restrict_with_error }
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
      it { is_expected.not_to allow_value(nil).for(:user_id) }
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

  describe "AASM states" do
    it "has active as initial state" do
      expect(create(:category)).to be_active
    end

    it "can transition from active to deleted" do
      category = create(:category)
      category.mark_as_deleted!
      expect(category).to be_deleted
    end

    it "can transition from deleted back to active" do
      category = create(:category, status: "deleted")
      category.restore!
      expect(category).to be_active
    end
  end

  describe "#destroy" do
    it "archives the category instead of deleting it" do
      category = create(:category)
      category.destroy
      expect(Category.exists?(category.id)).to be true
      expect(category.reload).to be_deleted
    end

    it "does not destroy associated transactions" do
      category = create(:category)
      account = create(:account, user: category.user)
      create(:transaction, category: category, user: category.user, account: account)
      category.destroy
      expect(category.transactions.count).to eq(1)
    end

    it "does not destroy associated budgets" do
      category = create(:category)
      currency = create(:currency)
      create(:budget, category: category, user: category.user, currency: currency)
      category.destroy
      expect(category.budgets.count).to eq(1)
    end

    it "permanently deletes when permanent_destroy: true" do
      category = create(:category)
      category_id = category.id
      category.destroy(permanent_destroy: true)
      expect(Category.exists?(category_id)).to be false
    end
  end

  describe ".available" do
    it "returns categories that are active and not inactive" do
      user = create(:user)
      active_category = create(:category, user: user)
      inactive_category = create(:category, user: user, name: "Inactive", inactive: true)
      deleted_category = create(:category, user: user, name: "Deleted", status: "deleted")
      inactive_and_deleted = create(:category, user: user, name: "Both", inactive: true, status: "deleted")

      available = user.categories.available
      expect(available).to include(active_category)
      expect(available).not_to include(inactive_category)
      expect(available).not_to include(deleted_category)
      expect(available).not_to include(inactive_and_deleted)
    end
  end
end
