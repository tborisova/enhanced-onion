module Mutations
  class DeleteUserMutation < BaseMutation
    argument :password, String, required: true

    field :profile, Types::ProfileType, null: false
    field :success, Boolean, null: false

    def resolve(input)
      profile = context[:current_user]

      success =
        if profile.valid_password? input[:password]
          profile.update! email: "deleted+#{profile.id}@deleted.com", name: 'Deleted'
          true
        end

      {profile:, success: !!success}
    end
  end
end
