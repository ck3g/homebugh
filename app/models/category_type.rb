class CategoryType < ApplicationRecord
  has_many :categories

  class << self
    def income
      1
    end

    # DEPRECATED
    def spending
      2
    end

    def expense
      2
    end
  end
end
