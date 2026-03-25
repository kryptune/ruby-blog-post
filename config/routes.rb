Rails.application.routes.draw do
  # post "/register", to: "users#create"
  # get "/register", to: "users#register"
  # get '/verify', to: 'users#verify'
  # get "/login", to: "auth#login"
  # post "/login", to: "auth#create"
  # # get "/refresh", to: "auth#refresh"
  # delete "/logout", to: "auth#logout"

  namespace :api do
    namespace :v1 do
      post   "register",  to:   "users#create"
      get    "register",  to:   "users#register"
      get    "verify",    to:   "users#verify"
      post   "login",     to:   "auth#create"
      get    "login",     to:   "auth#login"
      get    "refresh",   to:   "auth#refresh"
      delete "logout",    to:   "auth#logout"
    end
  end

  resources :blog_posts # shorthand for all the routes below, except root
  resources :blog_posts do
    member do
      get :translate
    end
    resources :comments, only: [:create, :destroy, :edit, :update]
  end

  # get "/blog_posts/new", to: "blog_posts#new", as: :new_blog_post
  # get "/blog_posts/:id", to: "blog_posts#show", as: :blog_post
  # patch "/blog_posts/:id", to: "blog_posts#update"
  # delete "/blog_posts/:id", to: "blog_posts#destroy"
  # get "/blog_posts/:id/edit", to: "blog_posts#edit", as: :edit_blog_post
  # post "/blog_posts", to: "blog_posts#create", as: :blog_posts

  root "api/v1/auth#login"
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
