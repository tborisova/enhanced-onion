module Mutations
  class EditRecipeMutation < BaseMutation
    include RecipeMutationFields

    argument :recipe_id, ID, required: true
    argument :title, String, required: false
    argument :description, String, required: false
    argument :url, String, required: false
    argument :photo_id, String, required: false
    argument :ingredients, [Types::RecipeIngredientInputType], required: false
    argument :categories, [ID], required: false
    argument :dietary_preference, Types::DietaryPreferenceKindType, required: false

    def resolve(input)
      result = EditRecipe.execute context[:current_user], input

      { recipe: result.recipe, errors: result.errors, user: context[:current_user] }
    end
  end
end
