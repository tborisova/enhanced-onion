class AddColumnToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :missing_name, :boolean, null: false, default: true
  end
end
