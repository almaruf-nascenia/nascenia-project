Rails.application.routes.draw do

  # resources :project_time_sheets
  resources :admins, only: [] do

    collection do
      get :manage_admin_and_users_list
      get :add_admin_form
      post :add_admin
    end

    member do
      get :make_user_admin
      get :remove_user_from_admin
    end

  end

  resources :developers do
    member do
      post 'unassign'
      get 'edit_developers_percentage'
    end

    collection do
      get 'engagement_report'
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
      post 'update_table_priority'
      post 'project_table_row_up'
      post 'project_table_row_down'
    end

    member do
      get 'dev_list'
      get :team_activity
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
