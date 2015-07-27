class Igram < ActiveRecord::Base
	mount_uploader :image_path, IgramUploader
end
