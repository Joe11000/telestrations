class AddPassingOrderToGames < ActiveRecord::Migration[5.0]
  def change
    add_column :games, :passing_order, :text, default: ''
  end
end
