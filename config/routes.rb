Rails.application.routes.draw do
  get 'sessions/new'

  resources :users
  resources :projects do
    resources :tasks do
      resources :comments
    end

    # member do
    #   get 'dead'
    #   post 'megakill'
    #
    # end
    # collection do
    #   post 'massmurder'
    # end
  end
  get    '/signup',  to: 'users#new'
  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'


end
