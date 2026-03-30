class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :blog_post
  validates :body, presence: true

  after_update_commit :broadcast_update_comment, if: :saved_change_to_body?
  after_create_commit :broadcast_new_comment
  after_destroy_commit :broadcast_delete_comment


  private 

  def broadcast_new_comment
    # Update comments to show the new comment at the top
    broadcast_replace_to [blog_post, :comments],
      target: "new_comment",
      partial: "comments/form",
      locals: { blog_post: blog_post, comment: blog_post.comments.build, logged_in: true }

    broadcast_prepend_to [blog_post, :comments],
      target: "comments",
      partial: "comments/comment",
      locals: {comment: self , logged_in: true}
  end

  def broadcast_delete_comment
    # Remove the comment from the comment section
    broadcast_remove_to [blog_post, :comments],
      target: "comment_#{id}"
  end

  def broadcast_update_comment
    broadcast_replace_to [blog_post, :comments], 
      target: "comment_#{id}",
      partial: "comments/comment",
      locals: {comment: self , logged_in: true}
  end

end
