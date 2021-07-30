Rails.application.routes.draw do
  get 'containers/index'
  get 'containers/new'
  post 'containers/create'
  get 'containers/run'
  get 'containers/delete'
  get 'images/index'
  get 'images/new'
  post 'images/create'
  get 'images/change_repository_tag'
  post 'images/change_repository_tag_do'
  get 'images/delete'
  get 'images/delete_2'

  root 'homes#index'

  resources :users

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
