module Types
  class RecipeType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :title, String, null: false
    field :description, String, null: true
    field :photo_url, String, null: true
    field :url, String, null: true
    field :categories, [RecipeCategoryType], null: false
    field :ingredients, [RecipeIngredientType], null: false
    field :dietary_preference, DietaryPreferenceKindType, null: true
    field :kind, RecipeKindType, null: false

    def id
      object.to_gid_param
    end

    def photo_url
      dataloader
        .with(Sources::ActiveStorageAttachmentsByRecord, name: "photo", record_type: "Recipe")
        .load(object.id)
        .then do |attachment|
          if attachment&.blob_id
            dataloader
              .with(Sources::ActiveStorageBlobsById)
              .load(attachment.blob_id)
              .then do |blob|
                blob ? Rails.application.routes.url_helpers.rails_blob_url(blob, only_path: true) : nil
              end
          else
            nil
          end
        end
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
      dietary_preference =
        dataloader.
        with(::Sources::ActiveRecordSource, DietaryPreference, :id).
        load(object.dietary_preference_id).first

      return nil unless dietary_preference

      case dietary_preference.name
      when 'meat'
        DietaryPreferenceKindType.values["MEAT"].value
      when 'vegeterian'
        DietaryPreferenceKindType.values["VEGETERIAN"].value
      else
        DietaryPreferenceKindType.values["VEGAN"].value
      end
    end

    def kind
      photo =
        dataloader.
        with(::Sources::ActiveRecordSource, ActiveStorage::Attachment, :record_id).
        load(object.id).first

      if photo.present?
        RecipeKindType.values["PHOTO"].value
      elsif object.url.present?
        RecipeKindType.values["URL"].value
      else
        RecipeKindType.values["MANUAL"].value
      end
    end
  end
end
