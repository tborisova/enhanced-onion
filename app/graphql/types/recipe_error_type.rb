module Types
  class RecipeErrorType < Types::BaseObject
    field :field, String, null: true
    field :message, String, null: false
  end
end
