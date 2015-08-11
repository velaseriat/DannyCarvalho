class Album < ActiveRecord::Base
	mount_uploader :image_filepath, AlbumImageUploader
end
