class Event < ActiveRecord::Base
	mount_uploader :image_filepath, ImageUploader
end
