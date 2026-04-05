class UpdateBlogPost
  include Interactor, SetBlogPostStatus

  def call
    blog_post_params = context.params
    blog_post = context.blog_post

    blog_post.assign_attributes(blog_post_params.except(:images))
    set_blog_post_status(blog_post)

    # Handle attachments before save
    blog_post.images.attach(blog_post_params[:images]) if blog_post_params[:images]

    # Purge selected images
    if context.remove_images
      context.remove_images.each do |id|
        blog_post.images.find(id).purge
      end
    end

    unless blog_post.save
      context.fail!(blog_post.errors.full_messages)
    end

    context.blog_post = blog_post
  end
end