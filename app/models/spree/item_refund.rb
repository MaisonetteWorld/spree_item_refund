module Spree
  class ItemRefund < Spree::Base
    include Spree::Core::NumberGenerator.new(prefix: 'IR', length: 9)
    include ItemRefund::StateMachine
    include ItemRefund::PrepareEventHandler
    include ItemRefund::RefundEventHandler
    extend DisplayMoney

    acts_as_paranoid
    self.whitelisted_ransackable_attributes = %w[description number state]

    has_many :item_refund_units, dependent: :destroy
    has_many :refunds

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
              :refund_type,
              presence: true
    money_methods :pre_tax_amount, :total

    class_attribute :refund_tax_calculator
    self.refund_tax_calculator = Calculator::ItemRefunds::DefaultTaxCalculator

    def editable?
      new?
    end

    def pre_tax_amount
      item_refund_units.sum :pre_tax_amount
    end
  end
end
