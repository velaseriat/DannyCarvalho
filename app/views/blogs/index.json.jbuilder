json.array!(@blogs) do |blog|
  json.extract! blog, :id, :blogId, :published, :blogUrl, :title, :content
  json.url blog_url(blog, format: :json)
end
