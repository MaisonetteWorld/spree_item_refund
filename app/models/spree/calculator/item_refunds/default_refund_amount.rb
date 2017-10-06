module Spree
  module Calculator::ItemRefunds
    class DefaultRefundAmount < Calculator
      def self.description
        Spree.t(:default_refund_amount)
      end

      def compute(item_refund_unit)
        value = weighted_order_adjustment_amount(item_refund_unit.inventory_unit) +
                weighted_line_item_pre_tax_amount(item_refund_unit.inventory_unit)
        value.round(2)
      end

      private

      def weighted_order_adjustment_amount(inventory_unit)
        inventory_unit.order.adjustments.eligible.non_tax.sum(:amount) *
          percentage_of_order_total(inventory_unit)
      end

      def weighted_line_item_pre_tax_amount(inventory_unit)
        inventory_unit.line_item.pre_tax_amount * percentage_of_line_item(inventory_unit)
      end

      def percentage_of_order_total(inventory_unit)
        return 0.0 if inventory_unit.order.pre_tax_item_amount.zero?
        weighted_line_item_pre_tax_amount(inventory_unit) / inventory_unit.order.pre_tax_item_amount
      end

      def percentage_of_line_item(inventory_unit)
        1 / BigDecimal.new(inventory_unit.line_item.quantity)
      end
    end
  end
end
