class CommentsController < ApplicationController
  before_action :authenticate_user, except: [ :create]
  before_action :set_comment, except: [ :create]

  def create
    @blog_post = BlogPost.find(params[:blog_post_id])
    @comment   = @blog_post.comments.build(comment_params)
    @comment.user = current_user  # assuming you have authentication

    if @comment.save
      redirect_to @blog_post, notice: "Comment added!"
    else
      render "blog_posts/show", status: :unprocessable_entity
    end
  end

  def edit; end



  def destroy
    @comment.destroy
    redirect_to @blog_post, notice: "Comment deleted."
  end

  def update
    if @comment.update(comment_params)
      redirect_to @blog_post, notice: "Comment has been successfully updated."
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

  def authenticate_user
    unless user_signed_in?
      redirect_to new_user_session_path, alert:"You must sign in to continue" 
    end
  end

end