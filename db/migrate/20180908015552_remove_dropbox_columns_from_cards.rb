class RemoveDropboxColumnsFromCards < ActiveRecord::Migration[5.2]
  def change
    change_table :cards do |t|
      t.remove :drawing_file_name,  \
               :drawing_content_type, \
               :drawing_file_size, \
               :drawing_updated_at


    end
  end
end
