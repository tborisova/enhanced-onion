module Mutations
  class UpdateProfileMutation < BaseMutation
    argument :name, String, required: true

    field :profile, Types::ProfileType, null: false

    def resolve(input)
      context[:current_user].update! name: input[:name]

      {profile: context[:current_user]}
    end
  end
end
