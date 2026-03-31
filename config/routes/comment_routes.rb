resources :blog_posts do
  member do
    get :translate
  end
  resources :comments, only: [:create, :destroy, :edit, :update]
end