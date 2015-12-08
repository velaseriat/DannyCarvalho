class RemoveTumblrIdFromAloha < ActiveRecord::Migration
  def change
    remove_column :alohas, :tumblr_id, :string
  end
end
