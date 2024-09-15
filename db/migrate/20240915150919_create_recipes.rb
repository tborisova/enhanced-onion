class CreateRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipes do |t|
      t.string :title, null: false
      t.string :url
      t.string :time
      t.text :description
      t.belongs_to :user

      t.timestamps
    end
  end
end
