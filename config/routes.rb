Rails.application.routes.draw do
  devise_for :users
  mount GraphiQL::Rails::Engine, at: '/graphiql', graphql_path: '/graphql' if Rails.env.development?
  post '/graphql', to: 'graphql#execute'
  get '/login', to: 'sessions#create'
  post '/register', to: 'registrations#create'
  post '/apple', to: 'apple_authentications#create'

  post '/magic_link', to: 'magic_links#create'

  namespace :web do
    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    get 'callback', to: 'sessions#callback'
    delete 'logout', to: 'sessions#destroy'
    get 'register', to: 'registrations#new'
    post 'register', to: 'registrations#create'
    post 'apple/callback', to: 'apple_authentications#create', as: :apple_callback
    resources :recipes, only: [:index, :show, :new, :create]
  end

  namespace :admin do
    get 'login', to: 'sessions#new'
    post 'login', to: 'sessions#create'
    get 'callback', to: 'sessions#callback'
    delete 'logout', to: 'sessions#destroy'
    resources :users, only: [:index, :show, :update]
    resources :plans, only: [:index, :new, :create, :edit, :update]
    resources :recipes, only: [:index, :show, :destroy]
    resources :categories, only: [:index, :new, :create, :destroy]
    resources :dietary_preferences, only: [:index, :new, :create, :destroy]
  end

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get 'up' => 'rails/health#show', as: :rails_health_check

  resources :uploads do
    post :upload, on: :collection
  end

  post '/', to: 'web/apple_authentications#create'
  # Defines the root path route ("/")
  # root "posts#index"
end
