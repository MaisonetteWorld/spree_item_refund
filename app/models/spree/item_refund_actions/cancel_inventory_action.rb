module Spree
  module ItemRefundActions
    class CancelInventoryAction
      attr_accessor :success
      attr_accessor :error

      def initialize(item_refund)
        item_refund.item_refund_units.each do |item_refund_unit|
          item_refund_unit.inventory_unit.cancel!
        end
        @success = true
      rescue StandardError => error
        @error = error.message
        @success = false
      end
    end
  end
end
