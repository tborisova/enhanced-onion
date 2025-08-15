module Mutations
  module RecipeMutationFields
    def self.included(base)
      base.field :recipe, Types::RecipeType, null: true
      base.field :user, Types::ProfileType, null: false
      base.field :errors, [Types::RecipeErrorType], null: true
    end
  end
end
