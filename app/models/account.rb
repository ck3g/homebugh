class Account < ActiveRecord::Base
  belongs_to :user
  has_many :cash_flows, :as => :from_account
  has_many :cash_flows, :as => :to_account

  validates_presence_of :name, :user_id

  def deposit(funds)
    self.funds += funds
  end

  def withdrawal(funds)
    self.funds -= funds
  end

end
