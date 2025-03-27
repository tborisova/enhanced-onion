module Mutations
  class CreateRecipeMutation < BaseMutation
    argument :title, String, required: true
    argument :description, String, required: false
    argument :url, String, required: false
    argument :photo_id, String, required: false
    argument :ingredients, [Types::RecipeIngredientInputType], required: false
    argument :categories, [ID], required: true
    argument :dietary_preference, Types::DietaryPreferenceKindType, required: false

    field :recipe, Types::RecipeType, null: true

    def resolve(input)
      recipe = CreateRecipe.execute input, context[:current_user]

      {recipe:}
    end
  end
end
