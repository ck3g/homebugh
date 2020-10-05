Homebugh::Application.routes.draw do
  mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/api/graphql"
  post "/api/graphql", to: "graphql#execute"

  resources :transactions, :cash_flows, only: [:index, :new, :create, :update, :destroy]
  resources :categories, :accounts, only: [:index, :new, :create, :edit, :update, :destroy]
  resources :statistics, only: [:index] do
    get :archived, on: :collection
  end
  resources :budgets
  resources :recurring_payments, only: [:index, :new, :create, :destroy]

  devise_for :users

  authenticated :user do
    root to: "transactions#index", as: :auth_root
    get 'users/delete'
    delete 'users/destroy'
  end

  post "/api/token" => "api/token#create"

  root to: "welcome#index"
end
