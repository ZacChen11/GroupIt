Rails.application.routes.draw do

  root to: 'sessions#welcome'
  get 'sessions/welcome'
  resources :users do
    member do
      get 'reset_password'
    end
  end
  resources :projects do
    collection do
      post 'filter'
    end
    resources :tasks do
      resources :comments, except:[:show]
    end
  end
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  # post   '/hours',   to: 'tasks#create_hour'
  resources :hours, only: [:create, :show]
  get     '/report', to: 'reports#generate'
  post     '/report', to: 'reports#search'
end
