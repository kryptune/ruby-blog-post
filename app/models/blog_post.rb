class BlogPost < ApplicationRecord
  validates :title, :body, presence: true
  enum :status, {draft: 0, scheduled: 1, published: 2}
  belongs_to :user
  has_many :comments, dependent: :destroy
  has_one_attached :cover_image
  has_many_attached :images

  after_update_commit :broadcast_blog_post_change
  after_create_commit :broadcast_new_blog_post
  after_destroy_commit :broadcast_delete_post


  private

  def broadcast_new_blog_post
    # Prepend new post to the grid
    broadcast_prepend_to "blog_posts",
      target: "blog_posts",
      partial: "blog_posts/blog_post",
      locals: { blog_post: self }

    # Update counter for new counts
    broadcast_update_to "blog_posts",
      target: "blog_posts_counter",
      partial: "blog_posts/counter",
      locals: { blog_posts: BlogPost.all, logged_in: true }
  end

  def broadcast_delete_post
    # Remove blog post from the grid 
      broadcast_remove_to "blog_posts", target: "blog_post_#{id}", partial: "blog_posts/blog_post", locals: { blog_post: self }

    # Update counter for the new counts
      broadcast_update_to "blog_posts", target: "blog_posts_counter", partial: "blog_posts/counter" , locals: { blog_posts: BlogPost.all, logged_in: true }
  end

  def broadcast_blog_post_change
    blog_post = self.reload
    if (img = images.first) && img.variable?
      img.variant(resize_to_fill: [300, 180]).processed rescue nil
    end

    broadcast_replace_to "blog_posts",
      target: "blog_post_#{id}",
      partial: "blog_posts/blog_post",
      locals: { blog_post: blog_post }

    # Only broadcast counter/status if they actually changed
    if saved_change_to_status?
      broadcast_update_to "blog_posts",
        target: "blog_post_status_#{id}",
        partial: "blog_posts/status",
        locals: { blog_post: blog_post }
      broadcast_update_to "blog_posts",
        target: "blog_posts_counter",
        partial: "blog_posts/counter",
        locals: { blog_posts: BlogPost.all, logged_in: true }
    end
  end

end

