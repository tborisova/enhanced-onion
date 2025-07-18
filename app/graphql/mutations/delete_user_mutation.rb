module Mutations
  class DeleteUserMutation < BaseMutation
    field :profile, Types::ProfileType, null: false
    field :success, Boolean, null: false

    def resolve
      profile = context[:current_user]

      success = profile.update! email: "deleted+#{profile.id}@deleted.com", name: 'Deleted'

      {profile:, success: !!success}
    end
  end
end
