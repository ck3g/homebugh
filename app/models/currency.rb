class Currency < ActiveRecord::Base
  has_many :accounts

  validates :name, presence: true, uniqueness: true
end
