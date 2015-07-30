Rails.application.routes.draw do
  resources :photos
  resources :igrams
  resources :products
  resources :blogs
  resources :videos
  resources :subscribers
  resources :events
  resources :songs
  resources :albums
  resources :alohas
  devise_for :users
  resources :users
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  
  authenticate :user do
    require 'sidekiq/web'
    mount Sidekiq::Web => '/sidekiq'
  end

  root 'alohas#index'

  get 'users/:id/update_events' => 'users#update_events'
  get 'users/:id/send_event_emails' => 'users#send_event_emails'
  get 'users/:id/update_youtube' => 'users#update_youtube'
  get 'users/:id/update_blogger' => 'users#update_blogger'
  get 'users/:id/update_about' => 'users#update_about'
  get 'users/:id/update_instagram' => 'users#update_instagram'
  get 'users/:id/send_custom_emails' => 'users#send_custom_emails'
  get 'users/:id/reinitialize_files' => 'users#reinitialize_files'
  get 'users/:id/start_scheduler' => 'users#start_scheduler'
  get 'users/:id/check_social_count' => 'users#check_social_count'
   get 'users/:id/console' => 'users#console'
  get 'about' => 'alohas#about'
  get 'unsubscribe' => 'subscribers#unsubscribe'
  delete 'unsubscribe' => 'subscribers#destroy'

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
