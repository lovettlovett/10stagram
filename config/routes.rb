InstarankApp::Application.routes.draw do

  resources :users do
    resources :handles
  end

  get "/login", to: "session#new"
  post "/session", to: "session#create"
  delete "/session", to: "session#destroy"

  root "welcome#index"
end
