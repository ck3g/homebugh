class Budget < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :currency

  validates :user, :category, :currency, presence: true
  validates :limit, presence: true, numericality: { greater_than: 0 }

  def expenses(date: Date.current)
    user.transactions
      .joins(:account)
      .where(created_at: date.beginning_of_month..date.end_of_month)
      .where(category_id: category.id)
      .where(:'accounts.currency_id' => currency.id)
      .pluck(:summ).sum
  end
end
