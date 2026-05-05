class TransactionBlueprint < Blueprinter::Base
  identifier :id

  fields :comment, :account_id, :category_id,
         :client_uuid, :created_at, :updated_at

  field :amount do |transaction|
    transaction.summ
  end
end
