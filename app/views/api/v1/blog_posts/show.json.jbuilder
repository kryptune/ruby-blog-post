json.extract! @blog_post, :id, :title, :body, :created_at, :updated_at

json.images @blog_post.images.map { |image| { url: url_for(image) } }

json.comments @comments do |comment|
  json.partial! "api/v1/comments/comment", comment: comment
end