class AddIndexInRecipeCategories < ActiveRecord::Migration[7.1]
  def change
    add_index :recipe_categories, [:recipe_id, :category_id], unique: true
  end
end
