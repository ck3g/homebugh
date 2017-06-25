require 'rails_helper'

RSpec.describe Budget, type: :model do
  it "has a valid factory" do
    expect(create :budget).to be_valid
  end

  describe ".associations" do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to :category }
    it { is_expected.to belong_to :currency }
  end

  describe ".validations" do
    context "with valid attributes" do
      subject { create :budget }
      it { is_expected.to validate_presence_of :user }
      it { is_expected.to validate_presence_of :category }
      it { is_expected.to validate_presence_of :currency }
      it { is_expected.to validate_presence_of :limit }
      it do
        is_expected.to validate_numericality_of(:limit)
          .is_greater_than(0)
      end
    end
  end
end
