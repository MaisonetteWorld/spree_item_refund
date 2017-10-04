module Spree
  module Admin
    class ItemRefundsController < ResourceController
      belongs_to 'spree/order', find_by: :number

      private

      def load_form_data
        load_item_refund_reasons
      end

      def load_item_refund_reasons
        @reasons = Spree::ItemRefundReason.all
      end
    end
  end
end
