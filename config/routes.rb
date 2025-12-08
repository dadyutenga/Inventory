Rails.application.routes.draw do
  # JWT Authentication routes
  get "login", to: "auth#login_page", as: :login
  post "login", to: "auth#login"
  delete "logout", to: "auth#logout", as: :logout
  get "register", to: "users#register_page", as: :register
  post "register", to: "users#create"

  # Devise routes are disabled - using JWT instead
  # devise_for :users

  # Root path
  root "dashboard#index"

  # Dashboard
  resources :dashboard, only: [ :index ] do
    collection do
      post :clear_cache
    end
  end

  # Laptops
  resources :laptops do
    member do
      delete :remove_image
    end
  end

  # Sales
  resources :sales, only: [ :index, :new, :create, :show ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
