class BlogPost < ApplicationRecord
  validates :title, :body, presence: true
  enum :status, {draft: 0, scheduled: 1, published: 2}
  has_many :comments, dependent: :destroy


  after_update_commit :broadcast_status_change, if: :saved_change_to_status?
  after_create_commit :broadcast_new_blog_post
  after_destroy_commit :broadcast_delete_post


  private

  def broadcast_status_change
    Rails.logger.info "Broadcasting status change for blog post #{id} to #{status}"
    # Update the status of blog post
      broadcast_replace_to "blog_posts", target: "blog_post_#{id}", partial: "blog_posts/blog_post", locals: { blog_post: self }
    # Update the counter for the published, scheduled and draft
      broadcast_update_to "blog_posts", target: "blog_posts_counter", partial: "blog_posts/counter" , locals: { blog_posts: BlogPost.all, user_signed_in: true }
  end

  def broadcast_new_blog_post
    # Update blog posts grid to show the new post
     broadcast_prepend_to "blog_posts",
      target: "blog_posts",
      partial: "blog_posts/blog_post",
      locals: { blog_post: self }

    # Update counter for the new counts
      broadcast_update_to "blog_posts", target: "blog_posts_counter", partial: "blog_posts/counter" , locals: { blog_posts: BlogPost.all, user_signed_in: true }
  end

  def broadcast_delete_post
    # Remove blog post from the grid 
      broadcast_remove_to "blog_posts", target: "blog_post_#{id}", partial: "blog_posts/blog_post", locals: { blog_post: self }

    # Update counter for the new counts
      broadcast_update_to "blog_posts", target: "blog_posts_counter", partial: "blog_posts/counter" , locals: { blog_posts: BlogPost.all, user_signed_in: true }
  end

end

