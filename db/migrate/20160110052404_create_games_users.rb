class CreateGamesUsers < ActiveRecord::Migration
  def change
    create_table :games_users do |t|
      t.references :user
      t.references :game
      t.string     :users_game_name, default: 'Ned Flanders'

      t.datetime   :deleted_at, index: true
      t.timestamps
    end
  end
end
