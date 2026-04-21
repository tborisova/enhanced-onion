Rails.application.routes.draw do
  devise_for :users
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?
  post '/graphql', to: 'graphql#execute'
  get '/login', to: 'sessions#create'
  post '/register', to: 'registrations#create'
  post '/apple', to: 'apple_authentications#create'

  post '/magic_link', to: 'magic_links#create'

  root to: 'web/recipes#index'
  get '/sign-in', to: 'web/sessions#new', as: :sign_in
  post '/sign-in', to: 'web/sessions#create'
  get '/callback', to: 'web/sessions#callback', as: :sign_in_callback
  post '/apple/callback', to: 'web/sessions#apple_callback', as: :apple_callback
  delete '/logout', to: 'web/sessions#destroy', as: :logout
  resources :recipes, only: [:index, :show], controller: 'web/recipes'

  namespace :admin do
    get '/', to: 'dashboard#index', as: :dashboard
    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    get 'callback', to: 'sessions#callback'
    delete 'logout', to: 'sessions#destroy'
    resources :users, only: [:index, :show, :update]
    resources :plans, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :recipes, only: [:index, :show, :destroy]
    resources :categories, only: [:index, :new, :create, :destroy]
    resources :dietary_preferences, only: [:index, :new, :create, :edit, :update, :destroy]
    resources :temporary_images, only: [:index, :destroy]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  resources :uploads do
    post :upload, on: :collection
  end
  # Defines the root path route ("/")
  # root "posts#index"
end
