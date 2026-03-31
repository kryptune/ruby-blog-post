json.blog_posts @blog_posts do |blog_post|
  json.partial! "api/v1/blog_posts/blog_post", blog_post: blog_post
end