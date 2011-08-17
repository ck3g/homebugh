class CategoryType < ActiveRecord::Base
  has_many :categories

  def self.income
    1
  end

  def self.spending
    2
  end

end
