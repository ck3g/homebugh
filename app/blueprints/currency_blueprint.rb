class CurrencyBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :unit, :created_at, :updated_at
end
