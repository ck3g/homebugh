class Category < ActiveRecord::Base
	has_many :transactions
  belongs_to :category_type

  validates_presence_of :name
end
