class AddDescriptionFirstToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :description_first, :boolean, default: true
  end
end
