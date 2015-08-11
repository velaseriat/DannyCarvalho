class Product < ActiveRecord::Base
	mount_uploader :image_filepath, ProductImageUploader
end
