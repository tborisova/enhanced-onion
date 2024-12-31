module Mutations
  class DeleteRecipeMutation < BaseMutation
    argument :recipe_id, ID, required: true

    field :recipe, Types::RecipeType, null: true

    def resolve(input)
      recipe = GlobalID::Locator.locate(input[:recipe_id])

      recipe = DeleteRecipe.execute context[:current_user], recipe

      {recipe:}
    end
  end
end
