module Spree
  module Admin
    class ItemRefundsController < ResourceController
      belongs_to 'spree/order', find_by: :number

      before_action :load_form_data, only: %i[new edit]
      create.fails  :load_form_data
      update.fails  :load_form_data

      def fire
        @item_refund.send("#{params[:e]}!")
        flash[:success] = Spree.t(:item_refund_updated)
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
        all_inventory_units = @item_refund.order.inventory_units
        associated_inventory_units = @item_refund.item_refund_units.map(&:inventory_unit)
        unassociated_inventory_units = all_inventory_units - associated_inventory_units

        new_units = unassociated_inventory_units.map do |new_unit|
          Spree::ItemRefundUnit.new(inventory_unit: new_unit).
            tap(&:set_default_pre_tax_amount)
        end
        @form_item_refund_units = (@item_refund.item_refund_units + new_units).sort_by(&:inventory_unit_id)
        # if @form_item_refund_units.size == 1
        #   @form_item_refund_units = @form_item_refund_units.first
        # end
      end
    end
  end
end
