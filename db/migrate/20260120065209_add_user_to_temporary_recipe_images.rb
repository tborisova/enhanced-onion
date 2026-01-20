class AddUserToTemporaryRecipeImages < ActiveRecord::Migration[7.1]
  def change
    add_reference :temporary_recipe_images, :user, foreign_key: true
  end
end
