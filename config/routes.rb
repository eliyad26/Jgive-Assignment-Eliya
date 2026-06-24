Rails.application.routes.draw do
  root "campaigns#index"

  resources :campaigns, only: [:index, :show] do
    resources :donations, only: [:create]
  end
end
