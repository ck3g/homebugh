class CategoryTypeBlueprint < Blueprinter::Base
  identifier :id

  field :name do |category_type|
    category_type.name == 'spending' ? 'expense' : category_type.name
  end
end
