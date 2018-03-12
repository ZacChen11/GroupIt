Rails.application.routes.draw do

  root to: 'users#profile'
  resources :users, except: [:index, :show, :destroy] do
    member do
      get 'reset_password'
    end
  end
  get '/users', to: 'administrators#index'
  get '/users/:id', to: 'administrators#show'
  delete 'users/:id', to: 'administrators#destroy'
  get 'user/profile', to: 'users#profile'
  namespace :administrators do
    get 'new'
    post 'create'
    get 'edit'
    patch 'update'
    put 'update'
  end

  resources :projects do
    resources :tasks do
      member  do
        get 'assign_task'
      end
      member do
        get 'new_subtask'
      end
      member do
        post 'create_subtask'
      end
      resources :hours, only: [:create, :show]
      resources :comments, except:[:show]
    end
  end
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  get     '/report', to: 'reports#generate'
  post     '/report', to: 'reports#search'
end
