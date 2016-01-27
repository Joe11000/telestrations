class AddDrawingColumnToCards < ActiveRecord::Migration
  def up
    add_attachment :cards, :drawing
  end

  def down
    remove_attachment :cards, :drawing
  end
end
