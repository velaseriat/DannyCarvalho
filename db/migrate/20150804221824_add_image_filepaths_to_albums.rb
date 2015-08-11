class AddImageFilepathsToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :image_filepath, :string
  end
end
