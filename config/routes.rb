Rails.application.routes.draw do
  post "/register", to: "users#create"
  get "/register", to: "users#register"
  get '/verify', to: 'users#verify'
  get "/login", to: "auth#login"
  post "/login", to: "auth#create"
  get "/refresh", to: "auth#refresh"
  delete "/logout", to: "auth#logout"

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

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # devise_for :users, controllers: {
  #   sessions: 'users/sessions'
  # }

  root "auth#login"
  mount LetterOpenerWeb::Engine, at: "/letter_opener"
end
