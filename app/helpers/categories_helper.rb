module CategoriesHelper
  def collection_of_types
    CategoryType.all.map do |type|
      [CategoryType.human_attribute_name(type.name), type.id]
    end
  end
end
