module Spree
  module Calculator::ItemRefunds
    class DefaultTaxCalculator
      class << self
        def call(item_refund)
          item_refund.item_refund_units.includes(:inventory_unit).each do |unit|
            set_tax!(unit)
          end
        end

        private

        def calculated_refund(unit)
          Spree::ItemRefundUnit.refund_amount_calculator.new.compute(unit)
        end

        def set_tax!(unit)
          calculated = calculated_refund(unit)
          percent_of_tax = if unit.pre_tax_amount <= 0 || calculated <= 0
                             0
                           else
                             unit.pre_tax_amount / calculated
                           end

          additional_tax_total = percent_of_tax * unit.inventory_unit.additional_tax_total
          included_tax_total   = percent_of_tax * unit.inventory_unit.included_tax_total

          unit.update_attributes!(
            additional_tax_total: additional_tax_total,
            included_tax_total: included_tax_total,
          )
        end
      end
    end
  end
end
