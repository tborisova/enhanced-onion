module Types
  class RecipeType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :photo, String, null: true
    field :url, String, null: true
    field :categories, [RecipeCategoryType], null: false
    field :ingredients, [RecipeIngredientType], null: false
    field :dietary_preferences, Types::RecipeDietaryPreferenceType.connection_type, null: false
    field :kind, RecipeKindType, null: false

    def id
      object.to_gid_param
    end

    def photo
      return nil unless object.photo.present?

      Rails.application.routes.url_helpers.rails_blob_url(object.photo, only_path: true)
    end

    def categories
      dataloader.with(::Sources::ActiveRecordSource, RecipeCategory, :recipe_id).load(object.id)
    end

    def ingredients
      dataloader.with(::Sources::ActiveRecordSource, RecipeIngredient, :recipe_id).load(object.id)
    end

    def dietary_preferences
      dataloader.with(::Sources::ActiveRecordSource, RecipeDietaryPreference, :recipe_id).load(object.id)
    end

    def kind
      if object.photo.present?
        RecipeKindType.values["PHOTO"].value
      elsif object.url.present?
        RecipeKindType.values["URL"].value
      else
        RecipeKindType.values["MANUAL"].value
      end
    end
  end
end
