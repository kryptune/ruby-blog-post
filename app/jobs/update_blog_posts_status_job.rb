class UpdateBlogPostsStatusJob < ApplicationJob
  queue_as :default

  def perform(*args)
    count = 0
    updatedPost = BlogPost.where("published_at <= ?", Time.current)
            .where(status: [0,1])
            .find_each do |post|
      post.published!
      count += 1
    end
    Rails.logger.info "Updated #{count} posts"
  end
end
