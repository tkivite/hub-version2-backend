# frozen_string_literal: true

Rails.application.routes.draw do
  resources :sales
  resources :collections
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  post 'authenticate', to: 'authentication#authenticate'
  post 'setpassword', to: 'passwords#set_password'
  post 'forgotpassword', to: 'passwords#forgot_password'
  # post 'users', to: 'users#create'
  # get 'users', to: 'users#index'
  post 'fetch_client', to: 'items#fetch_client'
  post 'save_facilities', to: 'items#save_facilities'

  resources :users do
  end
  resources :roles do
  end
  resources :assignments do
  end
  resources :partners do
  end
  resources :stores do
  end

  namespace :api do
    namespace :v1 do
      post 'disbursed/auto_release' => 'disburseds#auto_release'
      post 'disbursed/cancel_facilities' => 'disburseds#cancel_facilities'
    end
  end
end
