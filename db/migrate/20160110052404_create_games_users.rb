class CreateGamesUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :games_users do |t|
      t.references :user
      t.references :game
      t.string     :users_game_name, default: nil

      t.datetime   :deleted_at, index: true
      t.timestamps
    end
  end
end
