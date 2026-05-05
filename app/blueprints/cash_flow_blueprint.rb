class CashFlowBlueprint < Blueprinter::Base
  identifier :id

  fields :amount, :initial_amount, :from_account_id, :to_account_id,
         :client_uuid, :created_at, :updated_at
end
