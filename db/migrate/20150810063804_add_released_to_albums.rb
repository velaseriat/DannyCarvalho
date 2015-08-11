class AddReleasedToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :release, :datetime
  end
end
