Homebugh::Application.routes.draw do
  resources :transactions, only: [:index, :new, :create, :update, :destroy]
  resources :cash_flows, only: [:index, :new, :create, :destroy]
  resources :categories, only: [:index, :new, :create, :edit, :update, :destroy] do
    collection do
      get :archived
    end
    member do
      put :unarchive
    end
  end
  resources :accounts, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :statistics, only: [:index] do
    get :archived, on: :collection
  end
  resources :budgets
  resources :recurring_payments do
    member do
      put :move_to_next_payment
      post :create_transaction
    end
  end

  resources :recurring_cash_flows do
    member do
      put :move_to_next_transfer
      post :perform_transfer
    end
  end

  devise_for :users, controllers: { registrations: 'registrations' }

  authenticated :user do
    root to: "transactions#index", as: :auth_root
    get 'dashboard', to: 'dashboard#index'
    get 'users/delete'
    get 'users/profile', to: 'users#show'
    delete 'users/destroy'
  end

  namespace :api do
    namespace :v1 do
      resource :token, only: [:create, :destroy], controller: 'token'
      resources :accounts, only: [:index, :show, :create, :update, :destroy]
      resources :transactions, only: [:index, :show, :create, :update, :destroy]
      resources :cash_flows, only: [:index, :show, :create, :destroy]
      resources :budgets, only: [:index, :show, :create, :update, :destroy]
      resources :recurring_payments, only: [:index, :show, :create, :update, :destroy] do
        member do
          put :move_to_next_payment
          post :create_transaction
        end
      end
      resources :categories, only: [:index, :show, :create, :update, :destroy]
      resources :currencies, only: [:index, :show]
      resources :category_types, only: [:index, :show]
    end
  end

  get '/cookiepolicy' => "welcome#cookiepolicy"

  root to: "welcome#index"
end
