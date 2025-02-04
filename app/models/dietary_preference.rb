class DietaryPreference < ApplicationRecord
  has_many :recipes, inverse_of: :dietary_preference
end
