class Budget < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :currency

  validates :user, :category, :currency, presence: true
  validates :limit, presence: true, numericality: { greater_than: 0 }

  def expenses
    0
  end
end
