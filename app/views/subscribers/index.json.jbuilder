json.array!(@subscribers) do |subscriber|
  json.extract! subscriber, :id, :email, :opted_out
  json.url subscriber_url(subscriber, format: :json)
end
