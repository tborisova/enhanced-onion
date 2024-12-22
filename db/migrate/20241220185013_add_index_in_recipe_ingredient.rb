class AddIndexInRecipeIngredient < ActiveRecord::Migration[7.1]
  def change
    add_index :recipe_ingredients, [:recipe_id, :ingredient_id], unique: true
  end
end
