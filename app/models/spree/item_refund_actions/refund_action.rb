module Spree
  module ItemRefundActions
    class RefundAction
      attr_accessor :success
      attr_accessor :error

      def initialize(item_refund)
        refund_klass = item_refund.refund_type.constantize
        refund_klass.refund(item_refund)
        @success = true
      rescue StandardError => error
        @error = error.message
        @success = false
      end
    end
  end
end
