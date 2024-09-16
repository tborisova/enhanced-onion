module Types
  class IngredientType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :name, String, null: false

    def id
      object.to_gid_param
    end
  end
end
