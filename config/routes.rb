Rails.application.routes.draw do
  devise_for :users, controllers: {
    registrations: 'users/registrations',
    sessions: 'users/sessions',
    passwords: 'users/passwords',
  }, :skip => [:registrations]
  devise_scope :user do
    get '/users/sign_out' => 'devise/sessions#destroy'
  end
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end
  # , ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)
  root to: 'home#index'
  get 'home/index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  resources :measurements, only: [:index, :new, :create, :update] do
    collection do
      get :presence
    end
  end
  #resource :profile, only: [:show, :update], controller: 'users/profiles'

  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :measurements, only: [:index, :show, :update]
    end
    namespace :v2 do
      resources :measurements, only: [:index, :show, :update]
    end
  end
end
