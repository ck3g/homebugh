class CategoryType < ApplicationRecord
  has_many :categories

  class << self
    def income
      1
    end

    def spending
      2
    end
  end
end
