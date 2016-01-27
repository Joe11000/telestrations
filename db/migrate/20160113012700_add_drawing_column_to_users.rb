class AddDrawingColumnToUsers < ActiveRecord::Migration
  def up
    add_attachment :users, :provider_avatar_override
  end

  def down
    remove_attachment :users, :provider_avatar_override
  end
end
