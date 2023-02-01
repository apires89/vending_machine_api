Rails.application.routes.draw do
  devise_for :users,
             controllers: {
                 sessions: 'users/sessions',
                 registrations: 'users/registrations'
             }
  get '/member-data', to: 'members#show'
  namespace :api, defaults: { format: :json } do
    namespace :v1 do
      resources :products, only: [ :index, :show, :update, :create, :destroy ] do
      member do
        post :buy
      end
      end
      resources :users, only: [] do
        collection do
          patch :start_selling
          patch :deposit
          patch :reset
        end
      end
    end
  end
end
