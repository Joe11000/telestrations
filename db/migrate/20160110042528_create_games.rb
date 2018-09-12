class CreateGames < ActiveRecord::Migration[5.2]
  def change
    create_table :games do |t|
      t.integer :game_type, default: 0
      t.integer :status, default: 0
      t.string :join_code

      t.datetime   :deleted_at, index: true
      t.timestamps
    end
  end
end
