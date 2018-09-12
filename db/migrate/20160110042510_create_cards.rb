class CreateCards < ActiveRecord::Migration[5.2]
  def change
    create_table :cards do |t|
      t.references :uploader, class_name: 'User'
      t.references :parent_card, class_name: 'Card'
      t.references :starting_games_user
      t.references :idea_catalyst, class_name: 'GamesUser'
      t.text       :description_text, default: nil
      t.integer    :type

      t.datetime   :deleted_at, index: true
      t.timestamps
    end
  end
end
