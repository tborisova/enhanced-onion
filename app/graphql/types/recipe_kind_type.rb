module Types
  class RecipeKindType < GraphQL::Schema::Enum
    value "MANUAL"
    value "PHOTO"
    value "URL"
  end
end
