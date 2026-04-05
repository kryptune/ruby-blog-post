module SetBlogPostStatus
  extend ActiveSupport::Concern
  def set_blog_post_status(blog_post)
    if blog_post.published_at == nil
      blog_post.draft!
    elsif  blog_post.published_at > Time.current
      blog_post.scheduled!
    else
      blog_post.published!
    end
  end
end
