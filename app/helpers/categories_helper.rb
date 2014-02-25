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
end
