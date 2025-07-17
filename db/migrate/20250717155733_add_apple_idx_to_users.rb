class AddAppleIdxToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :apple_idx, :string
  end
end
