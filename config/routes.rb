Rails.application.routes.draw do
  devise_for :users
  devise_scope :user do
    post "users/guest_sign_in", to: "users/sessions#guest_sign_in"
  end

  root to: "homes#top"
  get "home/about" => "homes#about"
  get "search" => "searches#search"

  resources :users, only: [:index, :show, :edit, :update] do
    resource :relationships, only: [:create, :destroy], defaults: { format: "js" }
    get "followings" => "relationships#followings", as: "followings"
    get "followers" => "relationships#followers", as: "followers"
  end

  resources :books, only: [:index, :show, :edit, :create, :destroy, :update] do
    resource :favorites, only: [:create, :destroy], defaults: { format: "js" }
    resources :book_comments, only: [:create, :destroy], defaults: { format: "js" }
  end

  resources :chats, only: [:create, :destroy], defaults: { format: "js" }
  resources :rooms, only: [:show, :create]
end
