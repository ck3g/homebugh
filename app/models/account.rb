class Account < ActiveRecord::Base
  belongs_to :user
  has_many :cash_flows, as: :from_account
  has_many :cash_flows, as: :to_account

  validates_presence_of :name, :user_id

  def deposit(funds)
    raise ArgumentError if funds.nil?
    self.funds += funds
    self.save!
  end

  def withdrawal(funds)
    raise ArgumentError if funds.nil?
    self.funds -= funds
    self.save!
  end

end
