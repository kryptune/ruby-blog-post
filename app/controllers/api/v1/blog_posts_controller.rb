class Api::V1::BlogPostsController < Api::V1::ApiController
  include Api::Authenticate, SetBlogPostStatus
  before_action only: [:create, :update] do
    check_rate_limit(:blog_post)
  end
  before_action :authenticate, except: [:show, :index, :translate]
  before_action :store_user_location!, if: :storable_location?
  before_action :set_blog_post, except: [ :index, :new, :create ]
  before_action :require_verified_user, except: [:index, :show , :translate]
  ALLOWED_STATUSES = %w[published draft scheduled]
  
  def index
    ordered_blog_posts =  BlogPost.all.order(updated_at: :desc)
    @blog_posts_all = ordered_blog_posts
    @blog_posts = logged_in? ? ordered_blog_posts : BlogPost.published.order(updated_at: :desc)

    if params[:status].present? && ALLOWED_STATUSES.include?(params[:status])
      @blog_posts = @blog_posts.public_send(params[:status])
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
    set_blog_post_status(@blog_post)
    @blog_post.save!
    render :create, status: :created, formats: [:json]
  end

  def edit; end

  def update
    result = UpdateBlogPost.call(params: blog_post_params, blog_post: @blog_post, remove_images: params[:blog_post][:remove_images])
    if result.success?
     render :update, status: :ok, formats: [:json]
    else
      render json: {error: result.message}
    end
  end


  def destroy
    if @blog_post.destroy
      render :destroy, status: :ok, formats: [:json]
    else
      render json: { errors:"Failed to delete blog post." }, status: :forbidden
    end

  end

  def translate
      translator = TranslationService.new
      result = translator.translate(@blog_post.body, params[:lang] || "es")
      @translated_body = result.to_s 
      render json: { translated_body: @translated_body }, status: :ok
  end 


  private

  def blog_post_params
    params.require(:blog_post).permit(:title, :body, :published_at, images: [])
  end

  def set_blog_post
    @blog_post = (logged_in? ? BlogPost : BlogPost.published).find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors:"Couldn't find BlogPost with 'id' = #{params[:id]}" }, status: :not_found and return
  end

  def require_verified_user
    return if current_user&.email_verified
    render json:{error: "Please verify your email."}, status: :forbidden and return
  end

  def storable_location?
    request.get? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

end
