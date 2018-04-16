module Spree
  Order.class_eval do
    has_many :item_refunds

    with_options dependent: :destroy do
      has_many :item_refunds, inverse_of: :order
    end

    def item_refunds_enabled?
      completed?
    end
  end
end
