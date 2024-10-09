module Types
  class RecipeType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :photo, String, null: true
    field :url, String, null: true
    field :categories, Types::RecipeCategoryType.connection_type, null: false
    field :ingredients, Types::RecipeIngredientType.connection_type, null: false
    field :dietary_preferences, Types::RecipeDietaryPreferenceType.connection_type, null: false
    field :kind, String, null: false # enum

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
        :photo
      elsif object.url.present?
        :url
      else
        :manual
      end
    end
  end
end
