class BlogPostsController < ApplicationController
  before_action :authenticate_user, except: [ :index, :show]
  before_action :store_user_location!, if: :storable_location?
  before_action :set_blog_post, except: [ :index, :new, :create ]

  def index
    @blog_posts = (user_signed_in? ? BlogPost.all : BlogPost.published).order(updated_at: :desc )
  end

  def show;  end

  def new
    @blog_post = BlogPost.new
  end

  def create
    @blog_post = BlogPost.new(blog_post_params)
    if @blog_post.save
      redirect_to @blog_post, notice: "Blog post was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @blog_post.update(blog_post_params)
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


  private

  def blog_post_params
    params.require(:blog_post).permit(:title, :body, :published_at)
  end

  def set_blog_post
    @blog_post = user_signed_in? ? BlogPost.all.find(params[:id]) : BlogPost.published.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to root_path, alert: "Blog post not found."
  end

  def  authenticate_user
    unless user_signed_in?
      redirect_to new_user_session_path, alert:"You must sign in to continue" 
    end
  end

  def storable_location?
    request.get? && !devise_controller? && !request.xhr?
  end

  def store_user_location!
    store_location_for(:user, request.fullpath)
  end
end
