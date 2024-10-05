class AddDietaryPreference < ActiveRecord::Migration[7.1]
  def change
    create_table :dietary_preferences do |t|
      t.string :name

      t.timestamps
    end
  end
end
