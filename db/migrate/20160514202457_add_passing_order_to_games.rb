class AddPassingOrderToGames < ActiveRecord::Migration[5.2]
  def change
    add_column :games, :passing_order, :string, default: ''
  end
end
