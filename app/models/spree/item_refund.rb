module Spree
  class ItemRefund < Spree::Base
    acts_as_paranoid

    belongs_to :order
    belongs_to :reason,
               class_name: 'Spree::ItemRefundReason',
               foreign_key: :item_refund_reason_id
    has_many :item_refund_units
    accepts_nested_attributes_for :item_refund_units, allow_destroy: true

    extend FriendlyId
    friendly_id :number, slug_column: :number, use: :slugged
    include Spree::Core::NumberGenerator.new(prefix: 'F')

    extend DisplayMoney
    money_methods :pre_tax_amount

    with_options presence: true do
      validates :number, length: { maximum: 32, allow_blank: true }, uniqueness: { allow_blank: true }
      validates :order_id
      validates :item_refund_reason_id
    end

    STATE_NEW = 'new'.freeze
    STATE_READY = 'ready'.freeze
    STATE_CLOSED = 'closed'.freeze

    def editable?
      state != STATE_CLOSED
    end

    def perform
      ActiveRecord::Base.transaction do
        adjust_order
        refund
      end
    end

    def pre_tax_amount
      item_refund_units.sum :pre_tax_amount
    end

    private

    def adjust_order
      true
    end

    def refund
      true
    end
  end
end
