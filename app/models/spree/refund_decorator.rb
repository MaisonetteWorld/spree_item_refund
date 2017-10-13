module Spree
  Refund.class_eval do
    with_options inverse_of: :refunds do
      belongs_to :item_refund
    end
  end
end
