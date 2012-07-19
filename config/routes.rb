Homebugh::Application.routes.draw do
  resources :transactions, :categories, :statistics, :accounts, :cash_flows

  devise_for :users

  root :to => "transactions#index"
end
