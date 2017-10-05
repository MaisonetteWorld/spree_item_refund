module Spree
  InventoryUnit.class_eval do
    has_many :item_refund_units, inverse_of: :inventory_unit
  end
end
