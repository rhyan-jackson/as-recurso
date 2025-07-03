Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  resource :registration, only: %i[new create]
  resources :onboarding

  resources :customers, only: %i[new create edit update destroy]
  resources :payments, only: %i[new create index]

  resources :stations, only: [ :index, :show ] do
    resources :rides, only: [ :new, :create ]
    resources :reservations, only: [ :new, :create ]
  end

  resources :rides, only: [ :create, :update ] do
    collection do
      get :start_confirm
    end
    member do
      get :end_confirm
    end
  end

  resources :stations, only: [ :index, :show ] do
    resources :reservations, only: [ :new, :create ]
  end

  resources :reservations, only: [ :show ] do
    member do
      patch :cancel
    end
  end
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  root "home#index"
end
