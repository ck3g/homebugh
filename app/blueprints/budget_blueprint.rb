class BudgetBlueprint < Blueprinter::Base
  identifier :id

  fields :category_id, :currency_id, :limit,
         :client_uuid, :created_at, :updated_at
end
