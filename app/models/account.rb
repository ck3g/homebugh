class Account < ActiveRecord::Base
  belongs_to :user
  has_many :cash_flows, :as => :from_account
  has_many :cash_flows, :as => :to_account

  validates_presence_of :name

  def deposit( funds )
    account = Account.find( self.id )
    account.funds += funds
    account.save!
  end

  def withdrawal( funds )
    account = Account.find( self.id )
    account.funds -= funds
    account.save!
  end

end
