Rails.application.routes.draw do
  devise_for :users, controllers: { omniauth_callbacks: 'oauth_callbacks' }
  devise_scope :user do
    get 'sign_in' => 'devise/sessions#new', as: :new_user_session
    delete 'sign_out' => 'devise/sessions#destroy', as: :destroy_user_session
  end

  get 'about' => 'home#about', as: :home_about
  get 'log_in' => 'home#request_authentication', as: :home_request_authentication
  get 'search' => 'searches#search', as: :search

  root 'home#about'
end
