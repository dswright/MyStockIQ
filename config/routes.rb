require 'sidekiq/web'

Rails.application.routes.draw do
 
  mount Sidekiq::Web, at: '/sidekiq'

  get 'stockprices/update'

#sessions new is the login page. 
  root  'sessions#new' 
  
  #this sends /newuser to the newuser index function in the controller this has to be plural,
  #to fit with Ruby conventions.
  get     'users'                        =>   'users#new' 
  post    'users'                        =>   'users#create'
  get     'users/:username'              =>   'users#show'                                              


  get     'login'                        =>   'sessions#new'
  post    'login'                        =>   'sessions#create'
  delete  'logout'                       =>   'sessions#destroy'

 
  get     'stocks/:ticker_symbol'        =>   'stocks#show'

  #post    'streams'                      =>   'streams#create'
  #delete  'streams/:id'                  =>   'streams#destroy'

  post    'likes'                        =>   'likes#create'

  post    'comments'                     =>   'comments#create'
  delete  'comments/:id'                 =>   'comments#destroy'

  post    'predictions'                  =>   'predictions#create'
  get     'predictions/:id'              =>   'predictions#show'

  post    'replies'                      =>   'replies#create'
  get     'replies/:id'                  =>   'replies#show'

  post    'predictionends'               =>   'predictionends#create'

  get     'graphimages'                  =>   'graphimages#show'

  resources :streams
  resources :relationships

  #post      'relationships'              =>   'relationships#create'
  #delete    'relationships/:id'          =>   'relationships#destroy'


  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

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
