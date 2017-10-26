module Spree
  class ItemRefund
    module RefundEventHandler
      extend ActiveSupport::Concern

      included do
        REFUND_ACTIONS = [
          ItemRefundActions::RefundAction,
          ItemRefundActions::OrderAdjustAction,
          ItemRefundActions::CancelInventoryAction,
          ItemRefundActions::CancelShipmentAction,
          ItemRefundActions::OrderFinalize
        ].freeze

        private

        def perform_refund
          ActiveRecord::Base.transaction do
            REFUND_ACTIONS.each do |action|
              perform_refund_action action
            end
          end
        end

        def perform_refund_action(klass)
          object = klass.new(self)
          raise("#{klass.name}::#{object.error}") unless object.success
          reload
        end
      end
    end
  end
end
