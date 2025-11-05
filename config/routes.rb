Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users, controllers: {
    registrations: "users/registrations"
  }
  resources :users, only: [ :show ]

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  get "switch_child_page", to: "children#switch_page", as: :switch_child_page
  post "switch_child", to: "children#switch", as: :switch_child

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
  resources :children do
   patch :update_daily_goal, on: :member
   resources :feeds
   resources :diapers
   resources :bottles
   resources :hydrations
   resources :baby_foods
   resources :sleep_records do
     collection do
        get :analysis
      end
    end
   resources :temperatures
   resources :baths
   resources :vaccinations
   resources :growths
  end

  resources :notification_settings, only: [ :update ]

  # ユーザー単位で schedules を管理
  resources :schedules

  # 日記投稿機能
  resources :diaries

  # パパママtips機能
  resources :tips, only: [ :index, :show ]

  resources :notifications, only: [ :index ] do
    collection do
      post :mark_all_as_read # ドロップダウン開いたらまとめて既読
    end
  end

  # 利用規約・プライバシーポリシー
  get "/terms", to: "static_pages#terms"
  get "/privacy", to: "static_pages#privacy"

  # Defines the root path route ("/")
  root "home#index"
end
