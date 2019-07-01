Rails.application.routes.draw do
  resources :products
  resources :users

  get 'users/search_by_iris', to: 'users#search_user_by_iris'
  post 'users/match_by_iris', to: 'users#match_by_iris'
  get 'users/search_by_dni', to: 'users#search_user_by_dni'
  post 'users/match_by_dni', to: 'users#match_by_dni'

  get 'products/search_product', to: 'products#search_product'
  post 'products/get_from_image', to: 'products#get_from_image'

  get 'auth', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  post 'login_iris', to: 'sessions#create_with_iris'
  delete 'logout', to: 'sessions#destroy'

  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'welcome#home'
end
