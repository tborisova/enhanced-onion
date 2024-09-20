module Types
  class RecipeIngredientType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :name, String, null: false
    field :quantity, String, null: false

    def id
      object.to_gid_param
    end

    def name
      dataloader.
        with(::Sources::ActiveRecordSource, Ingredient, :id).
        request(object.ingredient_id).
        load(first.name)
    end
  end
end
