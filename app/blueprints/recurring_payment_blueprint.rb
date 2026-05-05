class RecurringPaymentBlueprint < Blueprinter::Base
  identifier :id

  fields :title, :amount, :account_id, :category_id,
         :frequency, :frequency_amount, :next_payment_on, :ends_on,
         :client_uuid, :created_at, :updated_at
end
