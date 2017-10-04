module Spree
  class ItemRefund
    belongs_to :order
    belongs_to :reason, class: :item_refund_reason, foreign_key: :item_refund_reason_id
    has_many :units, class: :item_refund_unit

    def perform
      ActiveRecord::Base.transaction do
        create_adjustment
        refund
      end
    end

    private

    def create_adjustment
      true
    end

    def refund
      true
    end
  end
end
