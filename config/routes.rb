Spree::Core::Engine.routes.draw do
  namespace :admin, path: Spree.admin_path do
    resources :item_refund_reasons, except: :show

    resources :orders, except: [:show] do
      resources :item_refunds do
        member do
          put :fire
        end
      end
    end
  end
end
