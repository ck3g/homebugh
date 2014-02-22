class Category < ActiveRecord::Base
  has_many :transactions
  belongs_to :category_type
  belongs_to :user

  validates :name, :category_type_id, :user_id, presence: true
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }

  delegate :name, to: :category_type, prefix: true

  scope :active, -> { where(inactive: false) }

  def income?
    category_type_id == CategoryType.income
  end
end
