class AddColumnUploadedInGameToCards < ActiveRecord::Migration[5.2]
  def change
    add_column :cards, :out_of_game_card_upload, :boolean, default: false, null: false
  end
end
