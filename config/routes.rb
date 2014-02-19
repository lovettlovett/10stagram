# == Route Map (Updated 2014-02-18 21:18)
#
#                  Prefix Verb   URI Pattern                                                   Controller#Action
#     user_handle_battles GET    /users/:user_id/handles/:handle_id/battles(.:format)          battles#index
#                         POST   /users/:user_id/handles/:handle_id/battles(.:format)          battles#create
#  new_user_handle_battle GET    /users/:user_id/handles/:handle_id/battles/new(.:format)      battles#new
# edit_user_handle_battle GET    /users/:user_id/handles/:handle_id/battles/:id/edit(.:format) battles#edit
#      user_handle_battle GET    /users/:user_id/handles/:handle_id/battles/:id(.:format)      battles#show
#                         PATCH  /users/:user_id/handles/:handle_id/battles/:id(.:format)      battles#update
#                         PUT    /users/:user_id/handles/:handle_id/battles/:id(.:format)      battles#update
#                         DELETE /users/:user_id/handles/:handle_id/battles/:id(.:format)      battles#destroy
#            user_handles GET    /users/:user_id/handles(.:format)                             handles#index
#                         POST   /users/:user_id/handles(.:format)                             handles#create
#         new_user_handle GET    /users/:user_id/handles/new(.:format)                         handles#new
#        edit_user_handle GET    /users/:user_id/handles/:id/edit(.:format)                    handles#edit
#             user_handle GET    /users/:user_id/handles/:id(.:format)                         handles#show
#                         PATCH  /users/:user_id/handles/:id(.:format)                         handles#update
#                         PUT    /users/:user_id/handles/:id(.:format)                         handles#update
#                         DELETE /users/:user_id/handles/:id(.:format)                         handles#destroy
#                   users GET    /users(.:format)                                              users#index
#                         POST   /users(.:format)                                              users#create
#                new_user GET    /users/new(.:format)                                          users#new
#               edit_user GET    /users/:id/edit(.:format)                                     users#edit
#                    user GET    /users/:id(.:format)                                          users#show
#                         PATCH  /users/:id(.:format)                                          users#update
#                         PUT    /users/:id(.:format)                                          users#update
#                         DELETE /users/:id(.:format)                                          users#destroy
#                   login GET    /login(.:format)                                              session#new
#                 session POST   /session(.:format)                                            session#create
#                         DELETE /session(.:format)                                            session#destroy
#                    root GET    /                                                             welcome#index
#

InstarankApp::Application.routes.draw do

  resources :users do
    resources :handles do
    	resources :battles
    end
  end

  get "/login", to: "session#new"
  post "/session", to: "session#create"
  delete "/session", to: "session#destroy"

  root "welcome#index"

end
