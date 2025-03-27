module Types
  class CategoryType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :name, String, null: false

    def id = object.to_gid_param
    def name = object.name.titleize
  end
end
