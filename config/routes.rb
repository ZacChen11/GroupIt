Rails.application.routes.draw do

  root to: 'sessions#welcome'
  get 'sessions/welcome'
  resources :users
  resources :projects do
    resources :tasks do
      resources :comments
    end
  end
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'

end
