# frozen_string_literal: true

module Types
  class QueryType < Types::BaseObject
    field :node, Types::NodeType, null: true, description: 'Fetches an object given its ID.' do
      argument :id, ID, required: true, description: 'ID of the object.'
    end

    def node(id:)
      context.schema.object_from_id(id, context)
    end

    field :nodes, [Types::NodeType, { null: true }], null: true,
                                                     description: 'Fetches a list of objects given a list of IDs.' do
      argument :ids, [ID], required: true, description: 'IDs of the objects.'
    end

    def nodes(ids:)
      ids.map { |id| context.schema.object_from_id(id, context) }
    end

    field :recipes, Types::RecipeType.connection_type, null: false do
      argument :category, String, required: false
      argument :term, String, required: false
      argument :dietary_preference, DietaryPreferenceKindType, required: false
    end

    def recipes(term: nil, category: nil, dietary_preference: nil)
      scope =
        Recipe
        .left_joins(:categories, :dietary_preference)
        .where(user: context[:current_user])
        .order('created_at DESC')

      scope = scope.where("title LIKE '%#{term}%'") if term.present?

      scope = scope.where(categories: { id: GlobalID.parse(category).model_id }) if category.present?

      scope = scope.where(dietary_preferences: { name: dietary_preference.downcase }) if dietary_preference.present?

      scope
    end

    field :categories, [Types::CategoryType], null: false
    def categories
      Category.all
    end

    field :recipe, Types::RecipeType, null: true do
      argument :id, ID, required: true
    end
    def recipe(id:)
      recipe = GlobalID::Locator.locate(id)

      return nil unless recipe.user == context[:current_user]

      recipe
    rescue ActiveRecord::RecordNotFound
      nil
    end

    field :profile, Types::ProfileType, null: false
    def profile = context[:current_user]
  end
end
