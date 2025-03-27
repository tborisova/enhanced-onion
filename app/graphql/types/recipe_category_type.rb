module Types
  class RecipeCategoryType < GraphQL::Schema::Object
    field :id, ID, null: false
    field :name, String, null: false

    def id
      object.to_gid_param
    end

    def name
      result = dataloader.with(::Sources::ActiveRecordSource, Category, :id).request(object.category_id)

      result.load.first.name.titleize
    end
  end
end
