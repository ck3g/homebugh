module CategoriesHelper
  def category_type(category)
    if category.inactive?
      "bg-warning"
    elsif category.income?
      "bg-success"
    else
      "bg-danger"
    end
  end

  def collection_of_types
    CategoryType.all.map do |type|
      [CategoryType.human_attribute_name(type.name), type.id]
    end
  end
end
