module DeleteRecipe
  extend self

  def execute(user, recipe)
    return nil unless user == recipe.user

    RecipeCategory.where(recipe:).delete_all
    RecipeIngredient.where(recipe:).delete_all
    recipe.delete
  end
end
