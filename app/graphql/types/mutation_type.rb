# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_recipe, mutation: Mutations::CreateRecipeMutation
    field :edit_recipe, mutation: Mutations::EditRecipeMutation
    field :delete_recipe, mutation: Mutations::DeleteRecipeMutation
  end
end
