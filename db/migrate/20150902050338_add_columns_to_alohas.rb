class AddColumnsToAlohas < ActiveRecord::Migration
  def change
    add_column :alohas, :soundcloud_id, :string
    add_column :alohas, :instagram_id, :string
    add_column :alohas, :youtube_id, :string
    add_column :alohas, :twitter_id, :string
    add_column :alohas, :tumblr_id, :string
  end
end
