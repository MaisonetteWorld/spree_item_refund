module Spree
  module ItemRefundActions
    class OrderAdjustAction
      attr_accessor :success
      attr_accessor :error

      def initialize(item_refund)
        @success = Spree::Adjustment.new(
          adjustable: item_refund.order,
          amount: -item_refund.total,
          eligible: true,
          label: "Item Refund ##{item_refund.number}",
          order: item_refund.order,
          source: item_refund,
          state: :closed
        ).save
      rescue StandardError => error
        @error = error.message
        @success = false
      end
    end
  end
end
