module Spree
  class ItemRefundUnit < Spree::Base
    acts_as_paranoid

    with_options inverse_of: :item_refund_units do
      belongs_to :item_refund
      belongs_to :inventory_unit
    end

    class_attribute :refund_amount_calculator
    self.refund_amount_calculator = Calculator::ItemRefunds::DefaultRefundAmount

    extend DisplayMoney
    money_methods :pre_tax_amount, :tax, :total

    def tax
      included_tax_total + additional_tax_total
    end

    def total
      pre_tax_amount + tax
    end

    def set_default_pre_tax_amount
      self.pre_tax_amount = refund_amount_calculator.new.compute(self)
    end
  end
end
