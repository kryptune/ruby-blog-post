class BlogPostsController < ApplicationController
  include RateLimitable, DecodeToken, RenderFlash
  skip_before_action :authorize, only: [:index, :show, :translate]  # guests can read
  before_action only: [:create] do
    check_rate_limit(limit: 20, window: 60)     # create post
  end
  before_action :store_user_location!, if: :storable_location?
  before_action :set_blog_post, except: [ :index, :new, :create ]
  before_action :require_verified_user, except: [:index, :show , :translate]

  def index
    @blog_posts_all = BlogPost.all.order(updated_at: :desc)
    @blog_posts = logged_in? ? BlogPost.all.order(updated_at: :desc) : BlogPost.published.order(updated_at: :desc)

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
      redirect_to @blog_post, notice: "Blog post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @blog_post.update(blog_post_params.except(:images))
      set_blog_post_status
      @blog_post.save
      # Attach new images if any were uploaded
      if blog_post_params[:images]
        @blog_post.images.attach(blog_post_params[:images])
      end
      # Purge selected images
      if params[:blog_post][:remove_images]
        params[:blog_post][:remove_images].each do |id|
          @blog_post.images.find(id).purge
        end
      end
      redirect_to @blog_post, notice: "Blog post was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @blog_post.destroy
      redirect_to root_path, notice: "Blog post was successfully deleted."
    else
      redirect_to root_path, alert: "Error deleting blog post."
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
    redirect_to root_path, alert: "Blog post not found."
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
    redirect_to api_v1_login_path unless current_user&.email_verified
  end

  def storable_location?
    request.get? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end

end
