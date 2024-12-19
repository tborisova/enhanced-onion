require 'rails_helper'

describe CreateRecipe do
  let(:user) { create :user }
  let(:recipe_attributes) { {title: 'Title', description: 'Description'} }

  it 'creates recipe with title and description' do
    recipe = CreateRecipe.execute({title: 'Title', description: 'Description'}, user)

    expect(recipe).to have_attributes(title: 'Title', description: 'Description', user_id: user.id)
  end

  it 'creates recipe with url' do
    recipe = CreateRecipe.execute({title: 'Title', description: 'Description', url: 'http://example.com'}, user)

    expect(recipe).to have_attributes({
      title: 'Title', description: 'Description', user_id: user.id, url: 'http://example.com'
    })
  end

  it 'does not create recipe with invalid url' do
    recipe = CreateRecipe.execute({title: 'Title', description: 'Description', url: 'url'}, user)

    expect(recipe).to eq nil
  end

  xit 'creates recipe with photo'

  it 'adds categories to the recipe' do
    recipe = CreateRecipe.execute(recipe_attributes.merge({categories: ['Soups']}), user)

    expect(recipe.categories.map(&:name)).to eq ['soups']
  end

  it 'does not create duplicated categories' do
    category = create :category, name: 'soups'

    recipe = CreateRecipe.execute(recipe_attributes.merge({categories: ['Soups', 'Winter']}), user)

    expect(recipe.categories.size).to eq 2
    expect(recipe.categories.map(&:id)).to include category.id
    expect(recipe.categories.map(&:name)).to match_array ['soups', 'winter']
  end

  it 'adds ingredients to the recipe' do
    ingredients = [
      {name: 'Pumpkin', quantity: '300 grams'},
      {name: 'Salt', quantity: '1 tbsp'},
      {name: 'Milk', quantity: '200 ml'},
      {name: 'Cumin', quantity: '1 tbsp'},
      {name: 'Ginger', quantity: '1 tbsp'}
    ]
    recipe = CreateRecipe.execute(recipe_attributes.merge({ingredients: ingredients}), user)

    expect(recipe.ingredients.map(&:name)).to match_array ['pumpkin', 'salt', 'milk', 'cumin', 'ginger']
  end

  it 'does not create duplicated ingredients' do
    pumpkin = create :ingredient, name: 'pumpkin'
    ingredients = [{name: 'Pumpkin', quantity: '300 grams'}]

    recipe = CreateRecipe.execute(recipe_attributes.merge({ingredients: ingredients}), user)

    expect(recipe.ingredients.map(&:id)).to eq [pumpkin.id]
  end
end
