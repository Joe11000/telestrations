class AddPlaceholderToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :placeholder, :boolean, default: false
  end
end
