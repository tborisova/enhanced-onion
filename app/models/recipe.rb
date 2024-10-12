class Recipe < ApplicationRecord
  belongs_to :user
  has_many :recipe_ingredients
  has_many :recipe_categories
  has_many :recipe_dietary_preferences
  has_one_attached :photo

  has_many :ingredients, through: :recipe_ingredients, class_name: 'Ingredient'
  has_many :categories, through: :recipe_categories, class_name: 'Category'
  has_many :dietary_preferences, through: :recipe_dietary_preferences, class_name: 'DietaryPreference'
end
