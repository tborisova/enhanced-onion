module Types
  class RecipeIngredientType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :name, String, null: false
    field :quantity, String, null: false

    def id
      object.to_gid_param
    end

    def name
      result = dataloader.
        with(::Sources::ActiveRecordSource, Ingredient, :id).
        request(object.ingredient_id)


      result.load.first.name
    end
  end
end
