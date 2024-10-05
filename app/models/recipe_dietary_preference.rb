class RecipeDietaryPreference < ApplicationRecord
  belongs_to :recipe
  belongs_to :dietary_preference
end
