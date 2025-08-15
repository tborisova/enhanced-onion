require 'rails_helper'

describe EditRecipe do
  it 'changes title' do
    recipe = create :recipe, title: 'Old title'

    EditRecipe.execute(recipe.user, { recipe_id: recipe.to_gid_param, title: 'New title' })

    expect(recipe.reload.title).to eq 'New title'
  end

  it 'does not changes title if title is not passed' do
    recipe = create :recipe, title: 'Old title'

    EditRecipe.execute(recipe.user, { recipe_id: recipe.to_gid_param, description: 'description' })

    expect(recipe.reload.title).to eq 'Old title'
  end

  it 'changes description' do
    recipe = create :recipe, description: 'old description'

    EditRecipe.execute(recipe.user, { recipe_id: recipe.to_gid_param, description: 'new description' })

    expect(recipe.reload.description).to eq 'new description'
  end

  it "does not changes the title if it's not passed" do
    recipe = create :recipe, title: 'old', description: 'description'

    EditRecipe.execute(recipe.user, { recipe_id: recipe.to_gid_param, title: 'new' })

    expect(recipe.reload.description).to eq 'description'
  end

  it 'changes url' do
    recipe = create :recipe, url: 'url'

    EditRecipe.execute(recipe.user, { recipe_id: recipe.to_gid_param, url: 'https://example.com' })

    expect(recipe.reload.url).to eq 'https://example.com'
  end

  it "does not changes url if it's not passed" do
    recipe = create :recipe, url: 'url'

    EditRecipe.execute(recipe.user, { recipe_id: recipe.to_gid_param, title: 'new' })

    expect(recipe.reload.url).to eq 'url'
  end

  it 'does not changes recipe if user is not the recipe user' do
    user = create :user
    recipe = create :recipe, title: 'title', description: 'description'

    EditRecipe.execute(user, { recipe_id: recipe.to_gid_param, title: 'new', description: 'newdescription' })

    expect(recipe.reload).to have_attributes(title: 'title', description: 'description')
  end

  it 'returns the recipe' do
    recipe = create :recipe, url: 'url'

    result = EditRecipe.execute(recipe.user, { recipe_id: recipe.to_gid_param, title: 'new' })

    expect(result.recipe).to eq recipe
  end

  it 'returns nil if recipe is not saved' do
    user = create :user
    recipe = create :recipe, title: 'title', description: 'description'

    result = EditRecipe.execute(user, { recipe_id: recipe.to_gid_param, title: 'new', description: 'newdescription' })

    expect(result.recipe).to eq nil
  end

  xit 'changes photo' do
  end

  it 'changes categories' do
    recipe = create :recipe
    first_category = create :category
    second_category = create :category
    create(:recipe_category, recipe:, category: first_category)

    EditRecipe.execute(
      recipe.user,
      {
        recipe_id: recipe.to_gid_param,
        categories: [first_category.to_gid_param, second_category.to_gid_param]
      }
    )

    expect(recipe.reload.categories.ids).to match_array [first_category.id, second_category.id]
  end

  it 'removes categories that are not in the list' do
    recipe = create :recipe
    soup = create :category
    create(:recipe_category, recipe:, category: create(:category))

    EditRecipe.execute(recipe.user, { recipe_id: recipe.to_gid_param, categories: [soup.to_gid_param] })

    expect(recipe.reload.categories.size).to eq 1
    expect(recipe.reload.categories.ids).to eq [soup.id]
  end

  it 'changes ingredients quantity' do
    recipe = create :recipe
    ingredient = create :ingredient, name: 'salt'
    salt = create(:recipe_ingredient, recipe:, ingredient:, quantity: '1 tbsp')
    ingredients = [
      { name: 'Salt', quantity: '2 tbsp' }
    ]

    EditRecipe.execute(recipe.user, { recipe_id: recipe.to_gid_param, ingredients: })

    expect(recipe.ingredients.count).to eq 1
    expect(salt.reload).to have_attributes(recipe_id: recipe.id, ingredient_id: ingredient.id, quantity: '2 tbsp')
  end

  it 'adds new ingredients' do
    recipe = create :recipe
    ingredient = create :ingredient, name: 'salt'
    create(:recipe_ingredient, recipe:, ingredient:, quantity: '1 tbsp')
    ingredients = [
      { name: 'salt', quantity: '1 tbsp' },
      { name: 'Milk', quantity: '200 ml' }
    ]

    EditRecipe.execute(recipe.user, { recipe_id: recipe.to_gid_param, ingredients: })

    recipe_ingredients = recipe.reload.recipe_ingredients.joins(:ingredient)
    expect(recipe_ingredients.size).to eq 2
    expect(recipe_ingredients.exists?(ingredients: { name: 'milk' }, quantity: '200 ml')).to eq true
  end

  it 'removes ingredients' do
    recipe = create :recipe
    salt = create :ingredient, name: 'salt'
    create(:recipe_ingredient, recipe:, ingredient: salt, quantity: '1 tbsp')
    milk = create :ingredient, name: 'milk'
    create(:recipe_ingredient, recipe:, ingredient: milk, quantity: '200 ml')
    ingredients = [{ name: 'Salt', quantity: '1 tbsp' }]

    EditRecipe.execute(recipe.user, { recipe_id: recipe.to_gid_param, ingredients: })

    recipe_ingredients = recipe.reload.recipe_ingredients.joins(:ingredient)
    expect(recipe_ingredients.size).to eq 1
    expect(recipe_ingredients.exists?(ingredients: { name: 'salt' }, quantity: '1 tbsp')).to eq true
  end
end
