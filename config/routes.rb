Rails.application.routes.draw do

  root to: 'users#profile'
  resources :users, except: [:index, :show, :destroy] do
    member do
      get 'index_task'
      get 'reset_password'
    end
  end
  get '/users', to: 'administrators#index_user'
  get '/users/:id', to: 'administrators#show_user'
  delete 'users/:id', to: 'administrators#destroy_user'
  get 'user/profile', to: 'users#profile'
  namespace :administrators do
    get 'new_user'
    post 'create_user'
    get 'edit_user'
    patch 'update_user'
    put 'update_user'
    get 'index_project'
    get 'index_task'
  end

  resources :projects do
    member  do
      get 'invite_participant'
    end
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
      resources :hours
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
