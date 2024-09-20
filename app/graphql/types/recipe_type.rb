module Types
  class RecipeType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :photo, String, null: true
    field :url, String, null: true
    field :categories, Types::RecipeCategoryType.connection_type, null: false
    field :ingredients, Types::RecipeIngredientType.connection_type, null: false

    def id
      object.to_gid_param
    end

    def categories
      dataloader.with(::Sources::ActiveRecordSource, RecipeCategory, :recipe_id).load(object.id)
    end

    def ingredients
      dataloader.with(::Sources::ActiveRecordSource, RecipeIngredient, :recipe_id).load(object.id)
    end
  end
end
