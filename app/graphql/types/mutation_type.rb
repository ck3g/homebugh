module Types
  class MutationType < Types::BaseObject
    field :health, String, null: false,
      description: "A healthy mutation"

    def health
      "A healty mutation!"
    end
  end
end
