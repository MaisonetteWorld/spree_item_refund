module Spree
  module ItemRefundTypes
    class StoreCredit
      class << self
        def payment_for_refund(item_refund)
          payments = item_refund.order.payments.valid
          payments.where.not(source_type: 'Spree::StoreCredit').first || payments.first
        end

        def refund(item_refund)
          store_credit = Spree::StoreCredit.new(store_credit_params(item_refund))
          if store_credit.save!
            # create refund entry for order totals purposes
            refund = item_refund.refunds.build(
              payment_id: payment_for_refund(item_refund).id,
              amount: item_refund.total,
              transaction_id: store_credit.generate_authorization_code,
              reason: Spree::RefundReason.return_processing_reason
            )

            if refund.save!
              # update order totals
              item_refund.order.updater.update
            end
          end
        end

        def store_credit_params(item_refund)
          category = Spree::StoreCreditCategory.find_by_name('Default') || Spree::StoreCreditCategory.first
          order = item_refund.order
          {
            user: order.user,
            amount: item_refund.total,
            category: category,
            created_by: Spree::User.admin.first,
            memo: "Item Refund #{item_refund.number} for Order ##{order.number}",
            currency: order.currency
          }
        end
      end
    end
  end
end
