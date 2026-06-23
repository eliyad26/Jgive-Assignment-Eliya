Rails.application.routes.draw do
  root "campaigns#show", defaults: { id: 1 }

  resources :campaigns, only: [:show] do
    resources :donations, only: [:create]
  end
end
