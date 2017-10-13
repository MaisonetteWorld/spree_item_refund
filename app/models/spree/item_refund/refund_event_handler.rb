module Spree
  class ItemRefund
    module RefundEventHandler
      extend ActiveSupport::Concern

      included do
        private

        def perform_refund_action(klass)
          object = klass.new(self)
          raise(object.error) unless object.success
        end

        def perform_refund
          ActiveRecord::Base.transaction do
            perform_refund_action(ItemRefundActions::OrderAdjustAction)
            perform_refund_action(ItemRefundActions::CancelInventoryAction)
            perform_refund_action(ItemRefundActions::RefundAction)
          end
        end
      end
    end
  end
end
