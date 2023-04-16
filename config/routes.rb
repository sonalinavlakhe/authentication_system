Rails.application.routes.draw do
  root 'static_pages#home'

  get 'sign_up', to: 'users#new'
  post 'sign_up', to: 'users#create'

  get 'login', to:'sessions#new'
  post 'login', to:'sessions#create'
  delete 'logout', to:'sessions#destroy'

  resources :confirmations, only: [:create, :new, :edit], param: :confirmation_token
end
