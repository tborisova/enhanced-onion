require 'rails_helper'

describe DeleteRecipe do
  it 'deletes recipe' do
    recipe = create :recipe

    DeleteRecipe.execute(recipe.user, recipe)

    expect(Recipe.find_by_id(recipe.id)).to eq nil
  end

  it 'deletes recipe categories' do
    recipe = create :recipe
    recipe_category = create(:recipe_category, recipe:)

    DeleteRecipe.execute(recipe.user, recipe)

    expect(RecipeCategory.find_by_id(recipe_category.id)).to eq nil
  end

  it 'deletes recipe ingredients' do
    recipe = create :recipe
    recipe_ingredient = create(:recipe_ingredient, recipe:)

    DeleteRecipe.execute(recipe.user, recipe)

    expect(RecipeIngredient.find_by_id(recipe_ingredient.id)).to eq nil
  end

  it 'does not delete general ingredients' do
    recipe = create :recipe
    ingredient = create(:ingredient)
    recipe_ingredient = create(:recipe_ingredient, recipe:, ingredient:)

    DeleteRecipe.execute(recipe.user, recipe)

    expect(Ingredient.find_by_id(ingredient.id)).to eq ingredient
  end

  it 'does not delete general categories' do
    recipe = create :recipe
    category = create(:category)
    recipe_category = create(:recipe_category, recipe:, category:)

    DeleteRecipe.execute(recipe.user, recipe)

    expect(Category.find_by_id(category.id)).to eq category
  end
end
