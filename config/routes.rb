require 'sidekiq/web'

Rails.application.routes.draw do
 
  mount Sidekiq::Web, at: '/sidekiq'

  get 'stockprices/update'

  #users new is the landing page with user signup.
  root  'users#new' 
  
  get     'user'                         =>   'users#index'
  post    'users'                        =>   'users#create'
  get     'users/:username'              =>   'users#show'
  delete  'users/:username'              =>   'users#destroy'

  get     'login'                        =>   'sessions#new'
  post    'login'                        =>   'sessions#create'
  get     'logout'                       =>   'sessions#destroy'

 
  get     'stocks/:ticker_symbol'        =>   'stocks#show'

  get     'stockprices/:ticker_symbol'   =>   'stockprices#show'
  get     'stockprices/hover_daily/:id'  =>   'stockprices#hover_daily'
  get     'stockprices/hover_intraday/:id' => 'stockprices#hover_intraday'

  post    'streams'                      =>   'streams#create'
  delete  'streams/:id'                  =>   'streams#destroy'
  post    'stream'                       =>   'streams#new'


  put     'like_create'                  =>   'likes#create'
  put     'like_destroy'                 =>   'likes#destroy'

  get     'comments'                     =>   'comments#index'
  get     'comments/:id'                 =>   'comments#by_id'


  post    'comments'                     =>   'comments#create'
  delete  'comments/:id'                 =>   'comments#destroy'

  post    'comment'                  =>   'comments#post'


  post    'predictions'                  =>   'predictions#create'
  get     'predictions/:id'              =>   'predictions#show'
  get     'predictions/hover_daily/:id'  =>   'predictions#hover_daily'
  get     'predictions/hover_intraday/:id' => 'predictions#hover_intraday'
  get     'predictions/details_hover_intraday/:id' => 'predictions#details_hover_intraday'
  get     'predictions/details_hover_daily/:id' => 'predictions#details_hover_daily'


  post    'reply'                        =>   'replies#new'

  post    'replies'                      =>   'replies#create'
  get     'replies/:id'                  =>   'replies#show'

  get     'feed'                         =>   'feeds#show'

  get     'settings'                     =>   'user_settings#show'
  post    'settings'                     =>   'user_settings#update'

  get     'welcome'                      =>   'welcome#show'
  post    'welcome'                      =>   'welcome#create'

  get     'referrals'                    =>    'referrals#new'
  post    'referrals'                    =>    'referrals#create'

  post    'waitingusers'                 =>    'waitingusers#create'

    get   'streams/:type/:id'           =>     'streams#index'

  resources :streams
  resources :relationships
  resources :predictionends

  get     'lp'                           =>    'lp#show'
  get     'unsubscribe'                  =>    'unsubscribe#show'
  post    'unsubscribe'                  =>    'unsubscribe#destroy'

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
