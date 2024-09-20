module Types
  class RecipeIngredientInputType < GraphQL::Schema::InputObject
    argument :name, String, required: true
    argument :quantity, String, required: true
  end
end
