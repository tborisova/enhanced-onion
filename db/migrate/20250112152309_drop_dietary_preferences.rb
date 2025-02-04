class DropDietaryPreferences < ActiveRecord::Migration[7.1]
  def change
    drop_table :recipe_dietary_preferences
  end
end
