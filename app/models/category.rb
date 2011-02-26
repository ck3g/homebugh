class Category < ActiveRecord::Base
	has_many :transactions
  belongs_to :type

  validates_presence_of :name
end
