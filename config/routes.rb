Homebugh::Application.routes.draw do
  resources :transactions, :cash_flows, only: [:index, :new, :create, :update, :destroy]
  resources :categories, :accounts, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :statistics, only: [:index] do
    get :archived, on: :collection
  end
  resources :budgets

  devise_for :users

  authenticated :user do
    root to: "transactions#index", as: :auth_root
  end

  root to: "welcome#index"
end
