module Spree
  module ItemRefundActions
    class OrderFinalize
      attr_accessor :success
      attr_accessor :error

      def initialize(item_refund)
        order = item_refund.order
        order.update_totals
        order.persist_totals
        order.updater.update_payment_state
        order.save

        order.shipments.where.not(state: :canceled).each do |shipment|
          shipment.update!(order)
        end
        @success = true
      rescue StandardError => error
        @error = error.message
        @success = false
      end
    end
  end
end
