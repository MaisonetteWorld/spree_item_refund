module Spree
  module ItemRefundTypes
    class OriginalPayment
      class << self
        def payment_for_refund(item_refund)
          payments = item_refund.order.payments.valid
          payments.where.not(source_type: 'Spree::StoreCredit').first
        end

        def refund
          refund = refunds.build(
            payment: payment_for_refund,
            amount: total,
            reason: Spree::RefundReason.return_processing_reason
          )
          refund.save!
        end
      end
    end
  end
end
