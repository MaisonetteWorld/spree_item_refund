module Spree
  class ItemRefund
    module PrepareEventHandler
      extend ActiveSupport::Concern

      included do
        private

        def calculate_tax
          refund_tax_calculator.call(self)
          reload

          # rounding every return item individually to handle edge cases for consecutive partial
          # returns where rounding might cause us to try to reimburse more than was originally billed
          # following logic from Spree core reimbusement
          calculated_total = item_refund_units.map { |unit| unit.total.to_d.round(2) }.sum
          update!(total: calculated_total)
        end

        def ensure_units_not_empty
          if item_refund_units.empty?
            errors.add(:base, Spree.t(:units_items_empty))
            false
          else
            true
          end
        end
      end
    end
  end
end
