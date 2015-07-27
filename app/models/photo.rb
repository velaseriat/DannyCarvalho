class Photo < ActiveRecord::Base
	mount_uploader :image_filepath, PhotoUploader
end
