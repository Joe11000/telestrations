class AddColumnUploadedInGameToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :uploaded_in_game, :boolean, default: true, null: false
  end
end
