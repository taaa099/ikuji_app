Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }

  resources :users, only: [:show]
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
   resources :sleep_records do
     collection do
        get :analysis  # 追加: 睡眠分析ページ
      end
    end
   resources :temperatures
   resources :baths
   resources :vaccinations
   resources :schedules
   resources :growths
  end

  resources :notifications, only: [ :index ] do
  collection do
    get :latest
  end
  member do
    patch :mark_as_read
  end
end

  # Defines the root path route ("/")
  root "home#index"
end
