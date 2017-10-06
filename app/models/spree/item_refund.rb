module Spree
  class ItemRefund < Spree::Base
    include Spree::Core::NumberGenerator.new(prefix: 'IR', length: 9)
    extend DisplayMoney

    self.whitelisted_ransackable_attributes = %w[description number state]
    acts_as_paranoid

    has_many :item_refund_units, dependent: :destroy
    belongs_to :order,
               class_name: 'Spree::Order',
               inverse_of: :item_refunds
    belongs_to :reason,
               class_name: 'Spree::ItemRefundReason',
               foreign_key: :item_refund_reason_id
    accepts_nested_attributes_for :item_refund_units,
                                  allow_destroy: true
    validates :order,
              :reason,
              presence: true
    money_methods :pre_tax_amount

    after_commit :validate_state

    state_machine initial: :new do
      event :renew do
        transition from: :prepared, to: :new
      end

      event :prepare do
        transition from: :new, to: :prepared
      end

      event :refund do
        transition from: :prepared, to: :refunded
      end
      before_transition to: :refunded, do: :perform_refund
    end

    def editable?
      new? || prepared?
    end

    def refundable?
      prepared?
    end

    def pre_tax_amount
      item_refund_units.sum :pre_tax_amount
    end

    private

    def adjust_order
      true
    end

    def perform_refund
      ActiveRecord::Base.transaction do
        adjust_order
        refund_units
      end
    end

    def refund_units
      true
    end

    def validate_state
      if new? && !item_refund_units.empty?
        prepare!
      elsif prepared? && item_refund_units.empty?
        renew!
      end
    end
  end
end
