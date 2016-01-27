class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.boolean :is_private, default: true
      t.boolean :is_active, default: true
      t.boolean :allow_additional_players, default: true
      t.string :join_code

      t.datetime   :deleted_at, index: true
      t.timestamps
    end
  end
end
