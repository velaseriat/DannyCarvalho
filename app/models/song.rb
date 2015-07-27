class Song < ActiveRecord::Base
	mount_uploader :filepath, SongUploader
end
