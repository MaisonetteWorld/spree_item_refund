module Spree
  module ItemRefundTypes
    class OriginalPayment
      class << self
        def calculate_amount_to_refund(payment, remaining_refund_amount)
          if payment.credit_allowed >= remaining_refund_amount
            remaining_refund_amount
          else
            remaining_refund_amount - payment.credit_allowed
          end
        end

        def payments(item_refund)
          item_refund.order.payments.valid.select do |payment|
            payment.credit_allowed > 0
          end
        end

        def create_refund(item_refund, payment, amount)
          refund = Spree::Refund.create(
            payment: payment,
            amount: amount,
            reason: item_refund.refund_reason
          )
          item_refund.refunds << refund
          item_refund.order.updater.update
        end

        # Break the refund into pieces to match payments' amounts
        def refund(item_refund)
          item_refund.save!
          remaining_refund_amount = item_refund.total
          refund_payments = payments(item_refund)
          refund_payments.each do |payment|
            next if remaining_refund_amount <= 0
            amount_to_refund = calculate_amount_to_refund(payment, remaining_refund_amount)
            remaining_refund_amount -= amount_to_refund

            create_refund(item_refund, payment, amount_to_refund)
          end
        end
      end
    end
  end
end
