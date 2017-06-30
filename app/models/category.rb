class Category < ActiveRecord::Base
  include Orderable

  belongs_to :category_type
  belongs_to :user
  has_many :budgets, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :aggregated_transactions, dependent: :destroy

  validates :name, :category_type_id, :user_id, presence: true
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }

  delegate :name, to: :category_type, prefix: true

  scope :active, -> { where(inactive: false) }
  scope :search, ->(term) { where("categories.name LIKE ?", "%#{term}%") if term.present? }

  def income?
    category_type_id == CategoryType.income
  end
end
