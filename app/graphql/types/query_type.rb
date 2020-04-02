module Types
  class QueryType < Types::BaseObject
    # Add root-level fields here.
    # They will be entry points for queries on your schema.

    field :health, String, null: false,
      description: "Health status"

    def health
      "Healty. As you can see."
    end
  end
end
