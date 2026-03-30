Rails.application.routes.draw do
  resources :sessions, only: [:index, :destroy] 
end