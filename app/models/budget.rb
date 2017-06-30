class Budget < ActiveRecord::Base
  belongs_to :user
  belongs_to :category
  belongs_to :currency

  validates :user, :category, :currency, presence: true
  validates :limit, presence: true, numericality: { greater_than: 0 }

  def expenses
    user.transactions
      .joins(:account)
      .where(created_at: DateTime.current.beginning_of_month..DateTime.current.end_of_month)
      .where(category_id: category.id)
      .where(:'accounts.currency_id' => currency.id)
      .pluck(:summ).sum
  end
end
