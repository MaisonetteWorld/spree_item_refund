module Spree
  module ItemRefundActions
    class CancelShipmentAction
      attr_accessor :success
      attr_accessor :error

      def initialize(item_refund)
        item_refund.item_refund_units.each do |item_refund_unit|
          handle_unit(item_refund_unit)
        end
        @success = true
      rescue StandardError => error
        @error = error.message
        @success = false
      end

      def handle_unit(item_refund_unit)
        item_refund = item_refund_unit.item_refund
        inventory_unit = item_refund_unit.inventory_unit
        shipment = inventory_unit.shipment

        if shipment.inventory_units.not_canceled.empty?
          # Cancel the original shipment
          # Its shipping cost is already included in total
        else
          # Move inventory unit to a new shipment
          # Cancel the new shipment
          shipment = shipment.dup
          shipment.number = nil
          shipment.cost = 0
          item_refund.order.shipments << shipment
          inventory_unit.update(shipment: shipment)
        end
        shipment.cancel!
        item_refund.order.reload
      end
    end
  end
end
