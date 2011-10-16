module CategoriesHelper

  def category_type(category)
    if category.inactive?
      "type_inactive"
    else
      "type_#{category.category_type_id}"
    end
  end

end
