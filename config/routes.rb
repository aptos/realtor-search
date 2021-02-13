Rails.application.routes.draw do
  root 'homes#index'
  get '/homes' => 'homes#index'
  get '/homes/archive/:property_id', to: 'homes#archive'
  get '/homes/like/:property_id', to: 'homes#like'
end
