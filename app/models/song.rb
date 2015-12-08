class Song < ActiveRecord::Base
	belongs_to :album
	mount_uploader :filepath, AlbumImageUploader
end
