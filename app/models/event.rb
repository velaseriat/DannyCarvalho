class Event < ActiveRecord::Base
	mount_uploader :image_filepath, ImageUploader
end

def get_info
	"#{dateTime.strftime("%m/%d")} - #{summary}"
end