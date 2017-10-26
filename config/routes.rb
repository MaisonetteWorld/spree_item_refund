Spree::Core::Engine.routes.draw do
  namespace :admin, path: Spree.admin_path do
    resources :orders, except: [:show] do
      resources :item_refunds do
        member do
          put :refund
          put :fire
        end
      end
    end
  end
end
