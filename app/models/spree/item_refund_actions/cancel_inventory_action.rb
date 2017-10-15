module Spree
  module ItemRefundActions
    class CancelInventoryAction
      attr_accessor :success
      attr_accessor :error

      def cancel_inventory_units(item_refund)
        item_refund.item_refund_units.each do |item_refund_unit|
          item_refund_unit.inventory_unit.cancel!
        end
      end

      def cancel_shipments(item_refund)
        item_refund.item_refund_units.each do |item_refund_unit|
          inventory_unit = item_refund_unit.inventory_unit
          shipment = inventory_unit.shipment

          unless shipment.inventory_units.not_canceled.size.zero?
            shipment = shipment.dup
            shipment.save
            inventory_unit.update(shipment: shipment)
          end
          Spree::Shipment.find_by_number(shipment.number).cancel!
        end
      end

      def initialize(item_refund)
        cancel_inventory_units(item_refund)
        cancel_shipments(item_refund)

        @success = true
      rescue StandardError => error
        @error = error.message
        @success = false
      end
    end
  end
end
