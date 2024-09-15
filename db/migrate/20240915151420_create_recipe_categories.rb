class CreateRecipeCategories < ActiveRecord::Migration[7.1]
  def change
    create_table :recipe_categories do |t|
      t.belongs_to :recipe
      t.belongs_to :category

      t.timestamps
    end
  end
end
