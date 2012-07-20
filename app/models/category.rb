class Category < ActiveRecord::Base
  attr_accessible :name, :inactive, :user_id, :category_type_id

  has_many :transactions
  belongs_to :category_type
  belongs_to :user

  validates :name, :category_type_id, :user_id, presence: true
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }

  scope :active, -> { where(inactive: false) }

  def income?
    category_type_id == CategoryType.income
  end
end
