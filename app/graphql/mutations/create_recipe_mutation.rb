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
    field :recipes_quota_reached, Boolean, null: false
    field :images_quota_reached, Boolean, null: false

    def resolve(input)
      recipe, quotas = CreateRecipe.execute input, context[:current_user]

      {recipe:, recipes_quota_reached: quotas[:recipe], images_quota_reached: quotas[:images] }
    end
  end
end
