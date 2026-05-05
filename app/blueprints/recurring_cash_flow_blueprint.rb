class RecurringCashFlowBlueprint < Blueprinter::Base
  identifier :id

  fields :amount, :from_account_id, :to_account_id,
         :frequency, :frequency_amount, :next_transfer_on, :ends_on,
         :client_uuid, :created_at, :updated_at
end
