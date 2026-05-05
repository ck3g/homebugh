class CategoryTypeBlueprint < Blueprinter::Base
  NAME_MAPPINGS = { 'spending' => 'expense' }.freeze

  identifier :id

  field :name do |category_type|
    NAME_MAPPINGS.fetch(category_type.name, category_type.name)
  end
end
