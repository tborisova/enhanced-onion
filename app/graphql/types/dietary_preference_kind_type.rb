module Types
  class DietaryPreferenceKindType < GraphQL::Schema::Enum
    value "MEAT"
    value "VEGETERIAN"
    value "VEGAN"
  end
end
