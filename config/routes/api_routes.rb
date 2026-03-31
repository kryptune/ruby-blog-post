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
    end
  end
