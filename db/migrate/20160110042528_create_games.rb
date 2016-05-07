class CreateGames < ActiveRecord::Migration
  def change
    create_table :games do |t|
      t.boolean :is_private, default: true
      t.string :status, default: 'pregame'
      t.string :join_code

      t.datetime   :deleted_at, index: true
      t.timestamps
    end
  end
end
