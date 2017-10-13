module Spree
  InventoryUnit.class_eval do
    has_many :item_refund_units, inverse_of: :inventory_unit

    state_machine do
      event :cancel! do
        transition to: :canceled, from: :on_hand
      end
    end

    scope :not_canceled, -> { where.not(state: canceled) }
  end
end
