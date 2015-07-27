json.array!(@videos) do |video|
  json.extract! video, :id, :title, :description, :url_path
  json.url video_url(video, format: :json)
end
