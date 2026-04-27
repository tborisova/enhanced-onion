module Mutations
  class CreateRecipeMutation < BaseMutation
    include RecipeMutationFields

    argument :title, String, required: true
    argument :description, String, required: false
    argument :url, String, required: false
    argument :photo_id, String, required: false
    argument :ingredients, [Types::RecipeIngredientInputType], required: false
    argument :categories, [ID], required: true
    argument :dietary_preference, Types::DietaryPreferenceKindType, required: true

    def resolve(input)
      service_input = input.to_h
      if service_input[:categories].present?
        service_input[:categories] = GlobalID::Locator.locate_many(service_input[:categories]).pluck(:id)
      end

      result = CreateRecipe.execute service_input, context[:current_user]

      { recipe: result.recipe, errors: result.errors, user: context[:current_user] }
    end
  end
end
