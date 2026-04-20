class Category < ApplicationRecord
  include AASM
  include Orderable

  belongs_to :category_type
  belongs_to :user
  has_many :budgets, dependent: :restrict_with_error
  has_many :transactions, dependent: :restrict_with_error
  has_many :aggregated_transactions, dependent: :restrict_with_error
  has_many :recurring_payments, dependent: :restrict_with_error

  validates :name, :category_type_id, :user_id, presence: true
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }

  delegate :name, to: :category_type, prefix: true

  aasm column: :status do
    state :active, initial: true
    state :deleted

    event :mark_as_deleted do
      transitions from: :active, to: :deleted
    end

    event :restore do
      transitions from: :deleted, to: :active
    end
  end

  scope :available, -> { active.where(inactive: false) }
  scope :search, ->(term) { where("categories.name LIKE ?", "%#{term}%") if term.present? }
  scope :income, -> { where(category_type_id: CategoryType.income) }
  scope :spending, -> { where(category_type_id: CategoryType.spending) }

  def income?
    category_type_id == CategoryType.income
  end

  def destroy(permanent_destroy: false)
    return super() if permanent_destroy

    mark_as_deleted!
  end
end
