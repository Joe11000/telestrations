class RemoveNotNullConstraintsForOmniauthLoginAttributes < ActiveRecord::Migration[5.2]
  def change
    change_column_null :users, :provider, true
    change_column_null :users, :name, true
    change_column_null :users, :uid, true
  end
end
