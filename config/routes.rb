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
  # post   '/hours',   to: 'tasks#create_hour'
  resources :hours, only: [:create, :show]
  get     '/report', to: 'users#search_report'
  post    '/report', to: 'users#create_report'

end
