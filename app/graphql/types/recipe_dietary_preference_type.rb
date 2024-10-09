module Types
  class RecipeDietaryPreferenceType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :name, String, null: false

    def id = object.to_gid_param

    def name
      result =
        dataloader.with(::Sources::ActiveRecordSource, DietaryPreference, :id).request(object.dietary_preference_id)

      result.load.first.name
    end
  end
end
