module Spree
  module ItemRefundActions
    class OrderFinalize
      attr_accessor :success
      attr_accessor :error

      def initialize(item_refund)
        order = item_refund.order
        canceled_shipment_numbers = order.shipments.where(state: 'canceled').map(&:number)
        order.update_totals
        order.save

        order.updater.update

        canceled_shipment_numbers.each do |number|
          shipment = Spree::Shipment.find_by_number(number)
          shipment.update(cost: 0)
          shipment.cancel!
        end
        @success = true
      rescue StandardError => error
        @error = error.message
        @success = false
      end
    end
  end
end
