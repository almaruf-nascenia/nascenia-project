Rails.application.routes.draw do

  # resources :project_time_sheets

  resources :developers do
    member do
      post 'unassign'
      get 'edit_developers_percentage'
    end
  end

  devise_for :users, :controllers => { :omniauth_callbacks => "users/omniauth_callbacks"}
  #devise_for :users do
  #  get '/users/sign_out' => 'devise/sessions#destroy'
  #end
  resources :projects do
    resources :project_time_sheets
    collection do
      post 'sortable'
      post 'update_developers_percentage'
    end
    member do
      get 'dev_list'
      get :show_project_time_sheets
      get :show_time_sheet_form
      get :edit_project_time_sheet
      post :add_time_sheet
      put :update_time_sheet
    end
  end

  get 'project_assign' => 'projects#project_assign'
  post 'projects/create_project_team', to: 'projects#create_project_team'
  get 'export' => 'projects#export'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  #root 'welcome#index'
  #root to: "home#index"
  root to: "projects#index"

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
