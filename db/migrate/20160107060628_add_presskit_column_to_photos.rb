class AddPresskitColumnToPhotos < ActiveRecord::Migration
  def change
    add_column :photos, :presskit, :boolean
  end
end
