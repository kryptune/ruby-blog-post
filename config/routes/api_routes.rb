  namespace :api do
    namespace :v1 do
      post   "register",  to:   "users#create"
      get    "register",  to:   "users#register"
      get    "verify",    to:   "users#verify"
      post   "login",     to:   "auth#create"
      get    "login",     to:   "auth#login"
      get    "refresh",   to:   "auth#refresh"
      delete "logout",    to:   "auth#logout"
      delete "logout_all", to:  "auth#logout_all"
      resources :blog_posts
      resources :blog_posts do
        member do
          get :translate
        end
        resources :comments, only: [:create, :destroy, :edit, :update]
      end
    end
  end
