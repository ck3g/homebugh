class Category < ActiveRecord::Base
  has_many :transactions
  belongs_to :category_type
  belongs_to :user

  validates :name, :category_type_id, :user_id, presence: true
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }

  scope :active, -> { where(inactive: false) }
end
