require 'rails_helper'

describe CreateRecipe do
  let(:recipe_attributes) { { title: 'Title', description: 'Description' } }

  it 'does not create recipe when recipe quota is reached' do
    user = create_user_with_plan recipes_quota: 0, images_quota: 0, is_free: false
    create :recipe, user: user

    response = CreateRecipe.execute({ title: 'Title', description: 'Description' }, user)

    expected_limits = {
      recipes_quota_reached: true,
      images_quota_reached: false,
      remaining_images_count: 0,
      remaining_recipes_count: 0
    }
    expect(response).to have_attributes(recipe: nil, limits: expected_limits)
  end

  it 'does not create recipe with photo if images quota is reached' do
    user = create_user_with_plan recipes_quota: 0, images_quota: 0, is_free: false
    create :recipe, :with_photo, user: user

    response = CreateRecipe.execute({ title: 'Title', description: 'Description', photo_id: '1' }, user)

    expected_limits = {
      recipes_quota_reached: true,
      images_quota_reached: true,
      remaining_images_count: 0,
      remaining_recipes_count: 0
    }
    expect(response).to have_attributes(recipe: nil, limits: expected_limits)
  end

  describe 'with unlimited quota' do
    let(:user) { create_user_with_plan is_free: true }

    it 'creates recipe with title and description' do
      response = CreateRecipe.execute({ title: 'Title', description: 'Description' }, user)

      expect(response.recipe).to have_attributes(title: 'Title', description: 'Description', user_id: user.id)
    end

    it 'creates recipe with url' do
      response = CreateRecipe.execute({ title: 'Title', description: 'Description', url: 'http://example.com' }, user)

      expected_attributes = {
        title: 'Title', description: 'Description', user_id: user.id, url: 'http://example.com'
      }
      expect(response.recipe).to have_attributes(expected_attributes)
    end

    it 'does not create recipe with invalid url' do
      response = CreateRecipe.execute({ title: 'Title', description: 'Description', url: 'url' }, user)

      expect(response.recipe).to eq nil
      expect(response.errors).to eq [{ field: 'url', message: 'invalid URL' }]
    end

    it 'creates recipe with photo' do
      photo = create :temporary_recipe_image
      response = CreateRecipe.execute({ title: 'Title', description: 'Description', photo_id: photo.id }, user)

      expect(response.recipe.photo_attachment).to be_present
    end

    it 'adds categories to the recipe' do
      category = create :category
      response = CreateRecipe.execute(recipe_attributes.merge({ categories: [category.to_gid_param] }), user)

      expect(response.recipe.categories.ids).to eq [category.id]
    end

    it 'adds ingredients to the recipe' do
      ingredients = [
        { name: 'Pumpkin', quantity: '300 grams' },
        { name: 'Salt', quantity: '1 tbsp' },
        { name: 'Milk', quantity: '200 ml' },
        { name: 'Cumin', quantity: '1 tbsp' },
        { name: 'Ginger', quantity: '1 tbsp' }
      ]
      response = CreateRecipe.execute(recipe_attributes.merge({ ingredients: ingredients }), user)

      expect(response.recipe.ingredients.map(&:name)).to match_array %w[pumpkin salt milk cumin ginger]
    end

    it 'does not create duplicated ingredients' do
      pumpkin = create :ingredient, name: 'pumpkin'
      ingredients = [{ name: 'Pumpkin', quantity: '300 grams' }]

      response = CreateRecipe.execute(recipe_attributes.merge({ ingredients: ingredients }), user)

      expect(response.recipe.ingredients.map(&:id)).to eq [pumpkin.id]
    end
  end

  def create_user_with_plan(plan_attributes = {})
    create :user, plan: create(:plan, **plan_attributes)
  end
end
