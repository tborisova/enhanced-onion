class AddIndexInRecipeDietaryPreference < ActiveRecord::Migration[7.1]
  def change
    add_index :recipe_dietary_preferences, [:recipe_id, :dietary_preference_id], unique: true
  end
end
