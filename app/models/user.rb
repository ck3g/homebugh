class User < ActiveRecord::Base
  has_many :aggregated_transactions, dependent: :destroy
  has_many :accounts, dependent: :destroy
  has_many :categories, dependent: :destroy
  has_many :transactions, dependent: :destroy
  has_many :cash_flows, dependent: :destroy

  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  def currencies
    accounts.map(&:currency).uniq
  end
end
