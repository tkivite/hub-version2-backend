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
    end
  end
end
