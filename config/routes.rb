Homebugh::Application.routes.draw do
  resources :transactions, :cash_flows, only: [:index, :new, :create, :destroy]
  resources :categories, :accounts, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :statistics, only: [:index]

  devise_for :users

  root :to => "transactions#index"
end
