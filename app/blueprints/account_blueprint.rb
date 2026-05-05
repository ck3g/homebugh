class AccountBlueprint < Blueprinter::Base
  identifier :id

  fields :name, :currency_id, :status, :show_in_summary,
         :client_uuid, :created_at, :updated_at

  field :balance do |account|
    account.funds
  end
end
