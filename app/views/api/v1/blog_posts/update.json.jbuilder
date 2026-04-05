if @blog_post.persisted?
  json.message "Blog post was successfully updated!"

  json.blog_post do 
    json.extract! @blog_post, :id, :title, :body, :created_at, :updated_at, :published_at
    json.images @blog_post.images.map { |image| { url: url_for(image) } }
  end

  json.comments @comments do |comment|
    json.partial! "api/v1/comments/comment", comment: comment
  end
else
    json.partial! 'api/v1/shared/errors', object: @blog_post
end