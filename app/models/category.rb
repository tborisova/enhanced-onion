class Category < ApplicationRecord

  def self.create_if_missing(category_names)
    category_names = category_names.map(&:downcase).map(&:strip)
    known_categories = Category.where(name: category_names)
    missing = category_names - known_categories.pluck(:name)
    categories = known_categories.pluck(:id)
    if missing.present?
      result = Category.insert_all missing.map {{name: _1}}, returning: %i(id)
      categories += result.rows.flatten
    end

    categories
  end
end
