class User < ActiveRecord::Base
  has_many :accounts
  has_many :categories
  has_many :transactions
  has_many :cash_flows

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

end
