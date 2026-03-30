class CommentsController < ApplicationController
  include RateLimitable
  before_action only: [:create] do
    check_rate_limit(limit: 30, window: 60)     # create comment
  end
  before_action :set_comment, except: [ :create]

  def create
    @blog_post = BlogPost.find(params[:blog_post_id])
    @comment   = @blog_post.comments.build(comment_params)
    @comment.user = current_user  # assuming you have authentication

    if @comment.save
      render_flash("Comment added!", @blog_post, type: :notice)
    else
      render "blog_posts/show", status: :unprocessable_entity
    end
  end

  def edit; end



  def destroy
    @comment.destroy
    render_flash("Comment deleted.", @blog_post, type: :notice)
  end

  def update
    if @comment.update(comment_params)
      render_flash("Comment has been successfully updated.", @blog_post, type: :notice)
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def comment_params
    params.require(:comment).permit(:body)
  end

  def set_comment
    @blog_post = BlogPost.find(params[:blog_post_id])
    @comment   = @blog_post.comments.find(params[:id])
  end

end