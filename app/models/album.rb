class Album < ActiveRecord::Base
	has_many :songs, dependent: :destroy
	mount_uploader :image_filepath, AlbumImageUploader
end
