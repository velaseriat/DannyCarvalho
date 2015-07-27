json.array!(@alohas) do |aloha|
  json.extract! aloha, :id, :name
  json.url aloha_url(aloha, format: :json)
end
