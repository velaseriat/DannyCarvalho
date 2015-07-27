json.array!(@photos) do |photo|
  json.extract! photo, :id, :image_filepath, :dateTime, :text
  json.url photo_url(photo, format: :json)
end
