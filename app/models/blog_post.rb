class BlogPost < ApplicationRecord
  validates :title, :body, presence: true
  enum :status, {draft: 0, scheduled: 1, published: 2}

  after_update_commit :broadcast_status_change, if: :saved_change_to_status?

  private

  def broadcast_status_change
    Rails.logger.info "Broadcasting status change for blog post #{id} to #{status}"
    broadcast_replace_to "blog_posts", target: "blog_post_#{id}", partial: "blog_posts/blog_post", locals: { blog_post: self }
  end

end

