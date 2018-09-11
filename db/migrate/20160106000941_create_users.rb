class CreateUsers < ActiveRecord::Migration[5.2]
  def change
    create_table :users do |t|
      t.string     :name, null: false
      t.string     :provider, null: false
      t.string     :uid, null: false
      t.string     :provider_avatar, null: false
      t.datetime   :deleted_at, index: true
      t.timestamps
    end
  end
end
