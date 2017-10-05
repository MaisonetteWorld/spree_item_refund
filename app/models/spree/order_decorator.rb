module Spree
  Order.class_eval do
    has_many :item_refunds

    def item_refunds_enabled?
      item_refunds.any? || shipments.where(state: :ready).any?
    end
  end
end
