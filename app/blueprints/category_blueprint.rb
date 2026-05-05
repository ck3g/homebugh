class CategoryBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :category_type_id, :inactive, :status,
         :client_uuid, :updated_at
end
