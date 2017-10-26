module Spree
  module ItemRefundTypes
    class StoreCredit < OriginalPayment
      class << self
        def payments(item_refund)
          item_refund.order.payments.valid.
            sort_by { |o| o.source_type == 'Spree::StoreCredit' ? 0 : 1 }.select do |payment|
            payment.credit_allowed > 0
          end
        end

        def create_refund(item_refund, payment, amount)
          authorization_code = store_credit_refund(item_refund, payment, amount)

          # create refund entry for order totals purposes
          # setting transaction_id prevents the refund from processing
          refund = Spree::Refund.create(
            payment: payment,
            amount: amount,
            transaction_id: authorization_code,
            reason: item_refund.refund_reason
          )
          item_refund.refunds << refund
          item_refund.order.updater.update
        end

        def store_credit_refund(item_refund, payment, amount)
          if payment.source_type != 'Spree::StoreCredit'
            store_credit = Spree::StoreCredit.new(store_credit_params(item_refund, amount: amount))
            store_credit.save
            store_credit.generate_authorization_code
          end
        end

        def store_credit_category(options)
          category_name = options[:category] || SpreeItemRefund.configuration.store_credit_category_name
          Spree::StoreCreditCategory.find_or_create_by!(name: category_name)
        end

        def store_credit_params(item_refund, options = {})
          order = item_refund.order
          {
            user: order.user,
            amount: item_refund.total || options[:amount],
            category: store_credit_category(options),
            created_by: Spree::User.admin.first,
            memo: "Item Refund #{item_refund.number} for Order ##{order.number}",
            currency: order.currency
          }
        end
      end
    end
  end
end
