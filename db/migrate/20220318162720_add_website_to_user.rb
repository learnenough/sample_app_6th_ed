class AddWebsiteToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :website, :string, unique: true
  end
end
