module Spree
  module Admin
    class ItemRefundsController < ResourceController
      belongs_to 'spree/order', find_by: :number

      before_action :load_form_data, only: %i[new edit fire refund]
      create.fails  :load_form_data
      update.fails  :load_form_data

      FIREABLE_EVENTS = %w[prepare renew].freeze

      def fire
        event = params[:e]
        if FIREABLE_EVENTS.include?(event)
          @item_refund.send("#{event}!")
          flash[:success] = Spree.t(:item_refund_updated)
        else
          flash[:error] = Spree.t(:cannot_fire_event)
        end
        redirect_to :back
      end

      def refund
        if @item_refund.prepared?
          @item_refund.refund!
        else
          flash[:error] = Spree.t('cannot_refund_not_prepared')
        end

        redirect_to :back
      end

      private

      def load_form_data
        load_item_refund_reasons
        load_item_refund_units
      end

      def load_item_refund_reasons
        @reasons = Spree::ItemRefundReason.all

        # Only allow an inactive reason if it's already associated to the Item Refund
        if @item_refund.reason && !@item_refund.reason.active?
          @reasons << @item_refund.reason
        end
      end

      def load_item_refund_units
        # Map inventory units which can be refunded
        all_inventory_units = @item_refund.order.inventory_units
        associated_inventory_units = @item_refund.order.item_refunds.map do |item_refund|
          item_refund.item_refund_units.map(&:inventory_unit)
        end.flatten
        unassociated_inventory_units = all_inventory_units - associated_inventory_units

        @form_new_item_refund_units = unassociated_inventory_units.map do |new_unit|
          Spree::ItemRefundUnit.new(inventory_unit: new_unit).
            tap(&:set_default_pre_tax_amount)
        end.sort_by(&:inventory_unit_id)
      end
    end
  end
end
