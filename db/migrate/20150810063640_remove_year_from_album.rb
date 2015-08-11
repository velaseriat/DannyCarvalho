class RemoveYearFromAlbum < ActiveRecord::Migration
  def change
    remove_column :albums, :year, :integer
  end
end
