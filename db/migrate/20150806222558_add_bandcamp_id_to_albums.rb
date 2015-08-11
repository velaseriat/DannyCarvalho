class AddBandcampIdToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :bandcamp_id, :string
  end
end
