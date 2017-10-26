module Spree
  class ItemRefund
    module PrepareEventHandler
      extend ActiveSupport::Concern

      included do
        private

        def calculate_totals
          refund_tax_calculator.call(self)
          reload
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
