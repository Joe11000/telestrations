class RemoveProviderAvatarFromUsers < ActiveRecord::Migration[5.2]
  def up
    remove_column :users, :provider_avatar, :string
  end

  def down
    add_column :users, :provider_avatar, :string, null: false
  end
end
