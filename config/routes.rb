Rails.application.routes.draw do
  get "sleep_records/index"
  get "sleep_records/show"
  get "sleep_records/new"
  get "sleep_records/create"
  get "sleep_records/edit"
  get "sleep_records/update"
  get "sleep_records/destroy"
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  post "switch_child", to: "children#switch", as: :switch_child

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  resources :children do
   resources :feeds
   resources :diapers
   resources :bottles
   resources :hydrations
   resources :baby_foods
  end

  # Defines the root path route ("/")
  root "home#index"
end
