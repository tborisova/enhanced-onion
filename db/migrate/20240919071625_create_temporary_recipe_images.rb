class CreateTemporaryRecipeImages < ActiveRecord::Migration[7.1]
  def change
    create_table :temporary_recipe_images do |t|

      t.timestamps
    end
  end
end
