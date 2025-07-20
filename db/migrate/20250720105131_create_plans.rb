class CreatePlans < ActiveRecord::Migration[7.1]
  def change
    create_table :plans do |t|
      t.string :name
      t.boolean :is_free
      t.integer :images_quota
      t.integer :recipes_quota
      t.decimal :price

      t.timestamps
    end
  end
end
