Rails.application.routes.draw do
  root 'frontpage#index'

  resources :hashtags, only: [:index, :show, :create, :update], param: :tag
  post 'hashtags/:tag/invite', to: 'hashtags#invite'
  post 'join', to: 'hashtags#join'
  delete 'leave', to: 'hashtags#leave'

  resources :users
  resources :feed, only: [:index]
  resources :search, only: [:index]
  resources :invite, only: [:index, :send_email]
  resources :user_hashtags, only: [:update]
  resources :notifications, only: [:index]

  get 'login', to: 'user#index'
  get 'login/:id', to: 'session#login'
  get 'logout', to: 'session#logout'

  get 'auth/shibboleth/callback', to: 'session#callback'

  match '/invite', to: 'invite#send_email', via: 'post'
  
  post 'notifications/:id', to: 'notifications#update', via: 'post'
  post 'firsttime', to: 'users#set_first_time_use', as: 'first_time'
end
