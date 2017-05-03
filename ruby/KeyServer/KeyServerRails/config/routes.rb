Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/keys/new' => 'keys#new'           # E1
  get '/keys' => 'keys#index'             # E2
  get '/keys/unblock' => 'keys#unblock'   # E3
  delete '/keys/:id' => 'keys#destroy'    # E4
  put '/keys/:id' => 'keys#update'        # E5
  # R1. All blocked keys should get released automatically within 60 secs if E3 is not called.
end
