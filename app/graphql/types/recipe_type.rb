module Types
  class RecipeType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :photo, String, null: true
    field :url, String, null: true
    field :categories, [RecipeCategoryType], null: false
    field :ingredients, [RecipeIngredientType], null: false
    field :dietary_preference, DietaryPreferenceKindType, null: true
    field :kind, RecipeKindType, null: false

    def id
      object.to_gid_param
    end

    def photo
      return nil unless object.photo.present?

      Rails.application.routes.url_helpers.rails_blob_url(object.photo, only_path: true)
    end

    def categories
      dataloader.
        with(::Sources::ActiveRecordSource, RecipeCategory, :recipe_id).
        load(object.id)
    end

    def ingredients
      dataloader.
        with(::Sources::ActiveRecordSource, RecipeIngredient, :recipe_id).
        load(object.id)
    end

    def dietary_preference
      return nil unless object.dietary_preference

      case object.dietary_preference.name
      when 'meat'
        DietaryPreferenceKindType.values["MEAT"].value
      when 'vegeterian'
        DietaryPreferenceKindType.values["VEGETERIAN"].value
      else
        DietaryPreferenceKindType.values["VEGAN"].value
      end
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
