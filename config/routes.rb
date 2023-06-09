Rails.application.routes.draw do
  root 'static_pages#home'

  get 'sign_up', to: 'users#new'
  post 'sign_up', to: 'users#create'

  get 'login', to: 'sessions#new'
  post 'login', to: 'sessions#create'
  delete 'logout', to: 'sessions#destroy'

  resources :phone_verifications, only: [:create, :new]
  post "/phone_verifications/resend_code", to: "phone_verifications#resend_code", as: :resend_phone_verification_code

  resources :confirmations, only: [:create, :new, :edit], param: :confirmation_token
  resources :passwords, only: [:create, :edit, :new, :update], param: :password_reset_token
end
