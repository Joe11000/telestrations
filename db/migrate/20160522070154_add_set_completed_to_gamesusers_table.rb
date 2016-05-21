class AddSetCompletedToGamesusersTable < ActiveRecord::Migration[5.0]
  def change
    add_column :games_users, :set_complete, :boolean, default: false
  end
end
