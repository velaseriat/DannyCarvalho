json.array!(@events) do |event|
  json.extract! event, :id, :summary, :dateTime, :timeZone, :location, :description, :colorId
  json.url event_url(event, format: :json)
end
