json.extract! blog_post, :id, :title, :body, :published_at

json.images blog_post.images.map { |image| { url: url_for(image) } }
