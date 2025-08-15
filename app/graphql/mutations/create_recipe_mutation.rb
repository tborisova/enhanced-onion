module Mutations
  class CreateRecipeMutation < BaseMutation
    include RecipeMutationFields

    argument :title, String, required: true
    argument :description, String, required: false
    argument :url, String, required: false
    argument :photo_id, String, required: false
    argument :ingredients, [Types::RecipeIngredientInputType], required: false
    argument :categories, [ID], required: true
    argument :dietary_preference, Types::DietaryPreferenceKindType, required: false

    def resolve(input)
      result = CreateRecipe.execute input, context[:current_user]
      p result
      { recipe: result.recipe, errors: result.errors, user: context[:current_user] }
    end
  end
end
