class AddDescriptionFirstToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :description_first, :boolean, default: true
  end
end
