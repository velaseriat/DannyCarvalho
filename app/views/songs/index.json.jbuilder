json.array!(@songs) do |song|
  json.extract! song, :id, :title, :duration, :filepath
  json.url song_url(song, format: :json)
end
