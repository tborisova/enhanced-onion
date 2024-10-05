class AddDietaryPreferenceRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipe_dietary_preferences do |t|
      t.belongs_to :recipe
      t.belongs_to :dietary_preference

      t.timestamps
    end
  end
end
