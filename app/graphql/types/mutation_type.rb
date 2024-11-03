# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_recipe, mutation: Mutations::CreateRecipeMutation
    field :login, mutation: Mutations::LoginMutation
  end
end
