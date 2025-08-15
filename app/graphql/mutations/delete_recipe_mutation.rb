module Mutations
  class DeleteRecipeMutation < BaseMutation
    include RecipeMutationFields

    argument :recipe_id, ID, required: true

    def resolve(input)
      DeleteRecipe.execute context[:current_user], input[:recipe_id]

      { recipe: nil, user: context[:current_user] }
    end
  end
end
