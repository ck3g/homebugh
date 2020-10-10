module Categorizable
  extend ActiveSupport::Concern

  included do
    belongs_to :category, touch: true

    scope :category, ->(category_id) { where(category_id: category_id) }
    scope :category_type, -> category_type_id {
      joins(:category).where(:'categories.category_type_id' => category_type_id)
    }

    delegate :category_type_id, to: :category, prefix: false, allow_nil: true
  end

  def income?
    category_type_id == CategoryType.income
  end
end
