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
    money_methods :pre_tax_amount, :total

    state_machine initial: :new do
      event :renew do
        transition from: :prepared, to: :new
      end

      event :prepare do
        transition from: :new, to: :prepared
      end
      before_transition to: :prepared, do: :ensure_units_not_empty
      after_transition to: :prepared, do: :calculate_tax

      event :refund do
        transition from: :prepared, to: :refunded
      end
      before_transition to: :refunded, do: :perform_refund
    end

    class_attribute :refund_tax_calculator
    self.refund_tax_calculator = Calculator::ItemRefunds::DefaultTaxCalculator

    def editable?
      new?
    end

    def pre_tax_amount
      item_refund_units.sum :pre_tax_amount
    end

    private

    def adjust_order
      true
    end

    def calculate_tax
      refund_tax_calculator.call(self)
      reload
      update!(total: calculated_total)
    end

    def calculated_total
      # rounding every return item individually to handle edge cases for consecutive partial
      # returns where rounding might cause us to try to reimburse more than was originally billed
      # following logic from Spree core reimbusement
      item_refund_units.map { |unit| unit.total.to_d.round(2) }.sum
    end

    def ensure_units_not_empty
      if item_refund_units.empty?
        errors.add(:base, Spree.t(:units_items_empty))
        false
      else
        true
      end
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
  end
end
