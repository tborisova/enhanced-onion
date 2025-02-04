module Mutations
  class EditRecipeMutation < BaseMutation
    argument :recipe_id, ID, required: true
    argument :title, String, required: false
    argument :description, String, required: false
    argument :url, String, required: false
    argument :photo_id, String, required: false
    argument :ingredients, [Types::RecipeIngredientInputType], required: false
    argument :categories, [String], required: false
    argument :dietary_preference, Types::DietaryPreferenceKindType, required: false

    field :recipe, Types::RecipeType, null: true

    def resolve(input)
      recipe = GlobalID::Locator.locate(input[:recipe_id])

      recipe = EditRecipe.execute context[:current_user], recipe, input

      {recipe:}
    end
  end
end
