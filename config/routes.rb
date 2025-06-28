Homebugh::Application.routes.draw do
  

  resources :transactions, :cash_flows, only: [:index, :new, :create, :update, :destroy]
  resources :categories, :accounts, only: [:index, :new, :create, :edit, :update, :destroy]
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

  devise_for :users, controllers: { registrations: 'registrations' }

  authenticated :user do
    root to: "transactions#index", as: :auth_root
    get 'users/delete'
    get 'users/profile', to: 'users#show'
    delete 'users/destroy'
  end

  post "/api/token" => "api/token#create"

  get '/cookiepolicy' => "welcome#cookiepolicy"

  root to: "welcome#index"
end
