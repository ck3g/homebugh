class Account < ActiveRecord::Base
  attr_accessible :name, :funds, :user_id

  belongs_to :user
  has_many :cash_flows, as: :from_account
  has_many :cash_flows, as: :to_account

  validates :name, :user_id, presence: true
  validates :name, uniqueness: { scope: :user_id, case_sensitive: false }

  def deposit(funds)
    funds ||= 0.0
    self.increment!(:funds, funds)
  end

  def withdrawal(funds)
    funds ||= 0.0
    self.decrement!(:funds, funds)
  end

end
