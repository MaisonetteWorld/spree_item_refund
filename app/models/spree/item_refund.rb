module Spree
  class ItemRefund < Spree::Base
    include Spree::Core::NumberGenerator.new(prefix: 'IR', length: 9)
    include ItemRefund::StateMachine
    include ItemRefund::Totals
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
    belongs_to :refund_reason
    accepts_nested_attributes_for :item_refund_units,
                                  allow_destroy: true
    validates :order,
              :refund_reason,
              :refund_type,
              presence: true
    money_methods :calculated_item_total, :calculated_ship_total, :pre_tax_amount, :total

    class_attribute :refund_tax_calculator
    self.refund_tax_calculator = Calculator::ItemRefunds::DefaultTaxCalculator

    def canceled_shipments
      @canceled_shipments ||= prepare_canceled_shipments
    end

    def editable?
      new?
    end

    def prepare_canceled_shipments
      inventory_units = item_refund_units.map(&:inventory_unit)
      order.shipments.select do |shipment|
        (shipment.inventory_units - inventory_units).empty? && shipment.state != 'shipped'
      end
    end
  end
end
