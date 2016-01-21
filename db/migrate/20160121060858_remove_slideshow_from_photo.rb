class RemoveSlideshowFromPhoto < ActiveRecord::Migration
  def change
    remove_column :photos, :slideshow, :boolean
  end
end
