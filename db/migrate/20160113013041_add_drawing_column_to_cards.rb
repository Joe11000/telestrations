class AddDrawingColumnToCards < ActiveRecord::Migration[5.2]
  def up
    add_attachment :cards, :drawing
  end

  def down
    remove_attachment :cards, :drawing
  end
end
