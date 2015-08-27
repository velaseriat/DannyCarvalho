class AddTrackNumToSongs < ActiveRecord::Migration
  def change
    add_column :songs, :track_num, :integer
  end
end
