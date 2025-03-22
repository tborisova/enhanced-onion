# frozen_string_literal: true

module Types
  class MutationType < Types::BaseObject
    field :create_recipe, mutation: Mutations::CreateRecipeMutation
    field :edit_recipe, mutation: Mutations::EditRecipeMutation
    field :delete_recipe, mutation: Mutations::DeleteRecipeMutation
    field :update_profile, mutation: Mutations::UpdateProfileMutation
    field :update_password, mutation: Mutations::UpdatePasswordMutation
    field :delete_user, mutation: Mutations::DeleteUserMutation
  end
end
