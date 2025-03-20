module Types
  class ProfileType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :name, String, null: false
    field :email, String, null: false

    def id = object.to_gid_param
  end
end
