module Types
  class DietaryPreferenceKindType < GraphQL::Schema::Enum
    value "MEAT"
    value "VEGETARIAN"
    value "VEGAN"
  end
end
