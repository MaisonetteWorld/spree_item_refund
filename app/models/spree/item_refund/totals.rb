module Spree
  class ItemRefund
    module Totals
      extend ActiveSupport::Concern

      included do
        # rounding every total element to handle edge cases for consecutive partial
        # refunds where rounding might cause us to try to reimburse more than was originally billed
        # Following logic from Spree core reimbusement
        def calculated_total
          calculated_item_total + calculated_ship_total
        end

        def calculated_item_total
          item_refund_units.map { |unit| unit.total.to_d.round(2) }.sum
        end

        def calculated_ship_total
          canceled_shipments.map { |shipment| shipment.cost.to_d.round(2) }.sum
        end

        def pre_tax_amount
          item_refund_units.map { |unit| unit.pre_tax_amount.to_d.round(2) }.sum
        end
      end
    end
  end
end
