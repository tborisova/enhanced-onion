module DeleteRecipe
  extend self

  def execute(user, id)
    recipe = GlobalID::Locator.locate(id)

    return nil unless user == recipe.user

    RecipeCategory.where(recipe:).delete_all
    RecipeIngredient.where(recipe:).delete_all
    recipe.delete
  end
end
