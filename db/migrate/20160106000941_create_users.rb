class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string     :name
      t.string     :provider
      t.string     :uid
      t.string     :provider_avatar
      t.datetime   :deleted_at, index: true
      t.timestamps
    end
  end
end
