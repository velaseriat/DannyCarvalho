json.array!(@igrams) do |igram|
  json.extract! igram, :id, :image_path, :link, :text, :dateTime, :url
  json.url igram_url(igram, format: :json)
end
