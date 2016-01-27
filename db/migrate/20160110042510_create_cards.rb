class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.references :uploader, class_name: 'User'
      t.references :parent_card, class_name: 'Card'
      t.references :idea_catalyst, class_name: 'GamesUser'
      t.text       :description_text, default: ''

      t.datetime   :deleted_at, index: true
      t.timestamps
    end
  end
end
