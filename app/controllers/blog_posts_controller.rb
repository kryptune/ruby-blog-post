class BlogPostsController < ApplicationController
  include RateLimitable, SetBlogPostStatus
  before_action only: [:create, :update] do
    check_rate_limit(:blog_post)
  end
  before_action :session_logged_in?, except: [:index, :show , :translate]
  before_action :store_user_location!, if: :storable_location?
  before_action :set_blog_post, except: [ :index, :new, :create ]
  before_action :require_verified_user, except: [:index, :show , :translate]
  ALLOWED_STATUSES = %w[published draft scheduled]

  
  def index
    ordered_blog_posts =  BlogPost.all.order(updated_at: :desc)
    @blog_posts_all = ordered_blog_posts
    @blog_posts =  BlogPost.published.order(updated_at: :desc)

    @user_blog_posts = ordered_blog_posts.where(user_id: current_user.id) if logged_in?
    if params[:status].present? && ALLOWED_STATUSES.include?(params[:status])
      @blog_posts = @user_blog_posts.public_send(params[:status])
    end

    @blog_posts = @blog_posts.order(created_at: :desc)

  end

  def show
    @comment   = @blog_post.comments.build
    @comments = @blog_post.comments.includes(:user, :blog_post).order(created_at: :desc)
  end


  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = BlogPost.new(blog_post_params)
    @blog_post.user_id = current_user.id
    set_blog_post_status(@blog_post)

    if @blog_post.save
      redirect_to @blog_post, notice: "Blog post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  
  def update
    result = UpdateBlogPost.call(params: blog_post_params, blog_post: @blog_post, remove_images: params[:blog_post][:remove_images])
    if result.success?
     redirect_to @blog_post, notice: "Blog post was successfully updated."
    else
      render_flash("Failed to update Blog post.", edit_blog_posts_path)
    end
  end

  def destroy
    if @blog_post.destroy
      redirect_to blog_posts_path, notice: "Blog post was successfully deleted."
    else
      render_flash("Error deleting blog post.", blog_posts_path )
    end
  end

  def translate
      translator = TranslationService.new
      result = translator.translate(@blog_post.body, params[:lang] || "es")
      @translated_body = result.to_s # force string
      render partial: "blog_posts/translate", locals: { translated_body: @translated_body }
  end 


  private

  def blog_post_params
    params.require(:blog_post).permit(:title, :body, :published_at, images: [])
  end

  def set_blog_post
    @blog_post = logged_in? ? BlogPost.all.find(params[:id]) : BlogPost.published.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render_flash("Blog post not found.", blog_posts_path)
  end

  def require_verified_user
    redirect_to web_login_path unless current_user&.email_verified
  end

  def storable_location?
    request.get? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

end
