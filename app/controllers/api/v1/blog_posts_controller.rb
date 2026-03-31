class Api::V1::BlogPostsController < Api::V1::ApiController
  include Api::Authenticate
  # before_action :check_rate_limit, only: [:create]
  before_action :authenticate, except: [:show, :index, :translate]
  before_action :store_user_location!, if: :storable_location?
  before_action :set_blog_post, except: [ :index, :new, :create ]
  before_action :require_verified_user, except: [:index, :show , :translate]
  
  def index
    ordered_blog_posts =  BlogPost.all.order(updated_at: :desc)
    @blog_posts_all = ordered_blog_posts
    @blog_posts = logged_in? ? ordered_blog_posts : BlogPost.published.order(updated_at: :desc)

    if params[:status].present?
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
    set_blog_post_status

    if @blog_post.save
      render :create, status: :created, formats: [:json]
    else
      render json: { errors: @blog_post.errors }, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    @blog_post.assign_attributes(blog_post_params.except(:images))
    set_blog_post_status
    if  @blog_post.save
      if blog_post_params[:images]
        @blog_post.images.attach(blog_post_params[:images])
      end
      # Purge selected images
      if params[:blog_post][:remove_images]
        params[:blog_post][:remove_images].each do |id|
          @blog_post.images.find(id).purge
        end
      end
      render :update, status: :ok, formats: [:json]
    else
      render :edit, status: :unprocessable_entity
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
      @translated_body = result.to_s # force string
      render partial: "blog_posts/translate", locals: { translated_body: @translated_body }
      Rails.logger.info "Translated body: #{@translated_body.inspect}"
  end 


  private

  def blog_post_params
    params.require(:blog_post).permit(:title, :body, :published_at, images: [])
  end

  def set_blog_post
    @blog_post = logged_in? ? BlogPost.all.find(params[:id]) : BlogPost.published.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    render json: { errors:"Couldn't find BlogPost with 'id' = 49" }, status: :not_found
  end

  def set_blog_post_status
    if @blog_post.published_at == nil
      @blog_post.draft!
    elsif  @blog_post.published_at > Time.current
      @blog_post.scheduled!
    else
      @blog_post.published!
    end
  end

  def require_verified_user
    render json:{error: "Please verify your email before logging in."}, status: :forbidden unless current_user&.email_verified
  end

  def storable_location?
    request.get? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

end
