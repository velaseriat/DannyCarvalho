class AddPricesToAlbums < ActiveRecord::Migration
  def change
    add_column :albums, :price, :string
  end
end
