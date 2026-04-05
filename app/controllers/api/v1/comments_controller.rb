class Api::V1::CommentsController < Api::V1::ApiController
  include RateLimitable
  before_action only: [:create] do
    check_rate_limit(:comment)     # create comment
  end
  before_action :set_comment, except: [ :create]

  def create
    @blog_post = BlogPost.find(params[:blog_post_id])
    @comment   = @blog_post.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      @new_comment   = @blog_post.comments.build
      render :create, status: :created, formats: [:json]
    else
      render json: { errors: @blog_post.errors }, status: :unprocessable_entity
    end
  end

  def edit; end



  def destroy
    @comment.destroy
    render_flash("Comment deleted.", @blog_post, type: :notice)
  end

  def update
    if @comment.update(comment_params)
      respond_to :turbo_stream
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